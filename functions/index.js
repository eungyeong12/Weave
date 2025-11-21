const {
  onCall,
  onRequest,
  HttpsError,
} = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const { initializeApp } = require("firebase-admin/app");
const axios = require("axios");

initializeApp();

// Secrets 정의
const naverClientId = defineSecret("NAVER_CLIENT_ID");
const naverClientSecret = defineSecret("NAVER_CLIENT_SECRET");
const tmdbApiKey = defineSecret("TMDB_API_KEY");

/**
 * 네이버 도서 검색 API를 호출하는 HTTP Cloud Function
 * Int64 문제를 피하기 위해 HTTP 함수로 변경
 * 기존 callable 함수와 충돌을 피하기 위해 새 이름 사용
 */
exports.searchBooksHttp = onRequest(
  {
    cors: true,
    maxInstances: 10,
    secrets: [naverClientId, naverClientSecret],
  },
  async (req, res) => {
    try {
      // CORS 헤더 설정
      res.set("Access-Control-Allow-Origin", "*");
      res.set("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
      res.set("Access-Control-Allow-Headers", "Content-Type");

      // OPTIONS 요청 처리
      if (req.method === "OPTIONS") {
        res.status(204).send("");
        return;
      }

      // 요청 데이터 파싱
      let query,
        start = 1,
        display = 10;

      if (req.method === "GET") {
        query = req.query.query;
        start = parseInt(req.query.start) || 1;
        display = parseInt(req.query.display) || 10;
      } else if (req.method === "POST") {
        const body = req.body;
        query = body.query;
        start = body.start || 1;
        display = body.display || 10;
      }

      if (!query || query.trim() === "") {
        throw new HttpsError("invalid-argument", "검색어를 입력해주세요.");
      }

      // Secrets에서 네이버 API 키 가져오기
      const clientId = naverClientId.value();
      const clientSecret = naverClientSecret.value();

      if (!clientId || !clientSecret) {
        throw new HttpsError(
          "internal",
          "네이버 API 키가 설정되지 않았습니다."
        );
      }

      // 네이버 검색 API 호출
      const response = await axios.get(
        "https://openapi.naver.com/v1/search/book.json",
        {
          params: {
            query: query,
            start: start,
            display: display,
            sort: "sim", // 정확도순 정렬
          },
          headers: {
            "X-Naver-Client-Id": clientId,
            "X-Naver-Client-Secret": clientSecret,
          },
        }
      );

      // JSON으로 직렬화하여 Int64 문제 해결
      // 모든 숫자를 문자열로 변환하여 Int64 문제 완전히 회피
      const convertNumbersToString = (obj) => {
        if (obj === null || obj === undefined) {
          return obj;
        }
        if (Array.isArray(obj)) {
          return obj.map(convertNumbersToString);
        }
        if (typeof obj === "object") {
          const result = {};
          for (const key in obj) {
            if (obj.hasOwnProperty(key)) {
              result[key] = convertNumbersToString(obj[key]);
            }
          }
          return result;
        }
        // 숫자를 문자열로 변환
        if (typeof obj === "number") {
          return obj.toString();
        }
        return obj;
      };

      const jsonData = JSON.parse(JSON.stringify(response.data));
      const convertedData = convertNumbersToString(jsonData);

      // HTTP 응답으로 반환
      res.status(200).json({
        success: true,
        data: convertedData,
      });
    } catch (error) {
      console.error("도서 검색 오류:", error);

      if (error.response) {
        // 네이버 API 오류
        res.status(500).json({
          success: false,
          error: `도서 검색 실패: ${error.response.status} - ${error.response.statusText}`,
        });
        return;
      }

      res.status(500).json({
        success: false,
        error: `도서 검색 중 오류가 발생했습니다: ${error.message}`,
      });
    }
  }
);

/**
 * 이미지 프록시 함수 - CORS 문제 해결
 * 네이버 쇼핑 이미지를 서버에서 가져와서 프록시로 제공
 */
exports.proxyImage = onRequest(
  {
    cors: true,
    maxInstances: 10,
  },
  async (req, res) => {
    try {
      // CORS 헤더 설정
      res.set("Access-Control-Allow-Origin", "*");
      res.set("Access-Control-Allow-Methods", "GET, OPTIONS");
      res.set("Access-Control-Allow-Headers", "Content-Type");

      // OPTIONS 요청 처리
      if (req.method === "OPTIONS") {
        res.status(204).send("");
        return;
      }

      // 이미지 URL 파라미터 가져오기
      const imageUrl = req.query.url;

      if (!imageUrl) {
        res.status(400).json({ error: "이미지 URL이 필요합니다." });
        return;
      }

      // 이미지 가져오기
      const imageResponse = await axios.get(imageUrl, {
        responseType: "arraybuffer",
        headers: {
          "User-Agent":
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
        },
      });

      // Content-Type 설정
      const contentType = imageResponse.headers["content-type"] || "image/jpeg";

      // 이미지 데이터 반환
      res.set("Content-Type", contentType);
      res.set("Cache-Control", "public, max-age=31536000"); // 1년 캐시
      res.status(200).send(Buffer.from(imageResponse.data));
    } catch (error) {
      console.error("이미지 프록시 오류:", error);
      res.status(500).json({
        error: `이미지 로딩 실패: ${error.message}`,
      });
    }
  }
);

/**
 * TMDb 영화 검색 API를 호출하는 HTTP Cloud Function
 */
exports.searchMoviesHttp = onRequest(
  {
    cors: true,
    maxInstances: 10,
    secrets: [tmdbApiKey],
  },
  async (req, res) => {
    try {
      // CORS 헤더 설정
      res.set("Access-Control-Allow-Origin", "*");
      res.set("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
      res.set("Access-Control-Allow-Headers", "Content-Type");

      // OPTIONS 요청 처리
      if (req.method === "OPTIONS") {
        res.status(204).send("");
        return;
      }

      // 요청 데이터 파싱
      let query,
        page = 1;

      if (req.method === "GET") {
        query = req.query.query;
        page = parseInt(req.query.page) || 1;
      } else if (req.method === "POST") {
        const body = req.body;
        query = body.query;
        page = body.page || 1;
      }

      if (!query || query.trim() === "") {
        res.status(400).json({
          success: false,
          error: "검색어를 입력해주세요.",
        });
        return;
      }

      // Secrets에서 TMDb API 키 가져오기
      const apiKey = tmdbApiKey.value();

      if (!apiKey) {
        res.status(500).json({
          success: false,
          error: "TMDb API 키가 설정되지 않았습니다.",
        });
        return;
      }

      // TMDb 검색 API 호출 (영화와 TV 모두 검색)
      const response = await axios.get(
        "https://api.themoviedb.org/3/search/multi",
        {
          params: {
            api_key: apiKey,
            query: query,
            page: page,
            language: "ko-KR",
          },
        }
      );

      // 숫자를 문자열로 변환하여 Int64 문제 회피
      const convertNumbersToString = (obj) => {
        if (obj === null || obj === undefined) {
          return obj;
        }
        if (Array.isArray(obj)) {
          return obj.map(convertNumbersToString);
        }
        if (typeof obj === "object") {
          const result = {};
          for (const key in obj) {
            if (obj.hasOwnProperty(key)) {
              result[key] = convertNumbersToString(obj[key]);
            }
          }
          return result;
        }
        if (typeof obj === "number") {
          return obj.toString();
        }
        return obj;
      };

      const jsonData = JSON.parse(JSON.stringify(response.data));
      const convertedData = convertNumbersToString(jsonData);

      // HTTP 응답으로 반환
      res.status(200).json({
        success: true,
        data: convertedData,
      });
    } catch (error) {
      console.error("영화 검색 오류:", error);

      if (error.response) {
        // TMDb API 오류
        res.status(500).json({
          success: false,
          error: `영화 검색 실패: ${error.response.status} - ${error.response.statusText}`,
        });
        return;
      }

      res.status(500).json({
        success: false,
        error: `영화 검색 중 오류가 발생했습니다: ${error.message}`,
      });
    }
  }
);
