const {
  onCall,
  onRequest,
  HttpsError,
} = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const { initializeApp } = require("firebase-admin/app");
const axios = require("axios");
const xml2js = require("xml2js");

initializeApp();

// Secrets 정의
const naverClientId = defineSecret("NAVER_CLIENT_ID");
const naverClientSecret = defineSecret("NAVER_CLIENT_SECRET");
const tmdbApiKey = defineSecret("TMDB_API_KEY");
const kopisApiKey = defineSecret("KOPIS_API_KEY");

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

/**
 * KOPIS 공연 검색 API를 호출하는 HTTP Cloud Function
 */
exports.searchPerformancesHttp = onRequest(
  {
    cors: true,
    maxInstances: 10,
    secrets: [kopisApiKey],
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
        page = 1,
        rows = 10;

      if (req.method === "GET") {
        query = req.query.query;
        page = parseInt(req.query.page) || 1;
        rows = parseInt(req.query.rows) || 10;
      } else if (req.method === "POST") {
        const body = req.body;
        query = body.query;
        page = body.page || 1;
        rows = body.rows || 10;
      }

      if (!query || query.trim() === "") {
        res.status(400).json({
          success: false,
          error: "검색어를 입력해주세요.",
        });
        return;
      }

      // Secrets에서 KOPIS API 키 가져오기
      const apiKey = kopisApiKey.value();

      if (!apiKey) {
        res.status(500).json({
          success: false,
          error: "KOPIS API 키가 설정되지 않았습니다.",
        });
        return;
      }

      // 날짜 범위 설정 (현재 날짜 기준으로 1년 전부터 1년 후까지)
      const today = new Date();
      const oneYearAgo = new Date(today);
      oneYearAgo.setFullYear(today.getFullYear() - 1);
      const oneYearLater = new Date(today);
      oneYearLater.setFullYear(today.getFullYear() + 1);

      const formatDate = (date) => {
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, "0");
        const day = String(date.getDate()).padStart(2, "0");
        return `${year}${month}${day}`;
      };

      const stdate = formatDate(oneYearAgo);
      const eddate = formatDate(oneYearLater);

      console.log("KOPIS API 호출 파라미터:", {
        service: apiKey ? "설정됨" : "없음",
        stdate,
        eddate,
        cpage: page,
        rows,
        shprfnm: query,
      });

      // KOPIS API 호출 (XML 응답)
      const response = await axios.get(
        "http://kopis.or.kr/openApi/restful/pblprfr",
        {
          params: {
            service: apiKey,
            stdate: stdate,
            eddate: eddate,
            cpage: page,
            rows: rows,
            shprfnm: query, // 공연명 검색
          },
          headers: {
            "Content-Type": "application/xml",
          },
          timeout: 10000, // 10초 타임아웃
          responseType: "text", // XML을 텍스트로 받기
        }
      );

      console.log("KOPIS API 응답 상태:", response.status);
      console.log("KOPIS API 응답 데이터 타입:", typeof response.data);

      // XML 응답을 JSON으로 변환 (KOPIS API는 XML을 반환)
      let jsonData;
      const responseData = response.data;

      console.log("응답 데이터 타입:", typeof responseData);
      console.log(
        "응답 데이터 (처음 500자):",
        typeof responseData === "string"
          ? responseData.substring(0, 500)
          : JSON.stringify(responseData).substring(0, 500)
      );

      if (typeof responseData === "string") {
        // XML 응답인 경우 파싱
        try {
          const parser = new xml2js.Parser({
            explicitArray: false,
            mergeAttrs: true,
            ignoreAttrs: false,
            trim: true,
          });
          jsonData = await parser.parseStringPromise(responseData);
          console.log("XML 파싱 성공, 구조:", Object.keys(jsonData));
        } catch (e) {
          console.error("XML 파싱 오류:", e.message);
          console.error("파싱 실패한 데이터:", responseData.substring(0, 1000));
          throw new Error(`XML 파싱 실패: ${e.message}`);
        }
      } else {
        // 이미 객체인 경우 (JSON 응답)
        jsonData = responseData;
        console.log("응답 데이터가 이미 객체입니다");
      }

      // KOPIS API 응답 구조 처리
      // XML 파싱 후 구조: { dbs: { db: [...] } } 또는 { dbs: { db: {...} } }
      let performancesData = jsonData;

      console.log(
        "파싱된 JSON 구조:",
        JSON.stringify(jsonData).substring(0, 500)
      );

      if (jsonData.dbs) {
        if (jsonData.dbs.db) {
          // db가 배열이 아닌 경우 배열로 변환
          const dbArray = Array.isArray(jsonData.dbs.db)
            ? jsonData.dbs.db
            : [jsonData.dbs.db];
          performancesData = { db: dbArray };
          console.log(`공연 데이터 ${dbArray.length}개 발견`);
        } else {
          performancesData = { db: [] };
          console.log("공연 데이터 없음 (dbs.db가 없음)");
        }
      } else if (jsonData.db) {
        // 직접 db가 있는 경우
        const dbArray = Array.isArray(jsonData.db)
          ? jsonData.db
          : [jsonData.db];
        performancesData = { db: dbArray };
        console.log(`공연 데이터 ${dbArray.length}개 발견 (직접 db)`);
      } else {
        console.log("알 수 없는 응답 구조:", Object.keys(jsonData));
        performancesData = { db: [] };
      }

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

      const convertedData = convertNumbersToString(performancesData);

      // HTTP 응답으로 반환
      res.status(200).json({
        success: true,
        data: convertedData,
      });
    } catch (error) {
      console.error("공연 검색 오류:", error);
      console.error("오류 스택:", error.stack);

      if (error.response) {
        // KOPIS API 오류
        console.error("KOPIS API 응답 오류:", {
          status: error.response.status,
          statusText: error.response.statusText,
          data: error.response.data,
        });
        res.status(500).json({
          success: false,
          error: `공연 검색 실패: HTTP ${error.response.status} - ${error.response.statusText}`,
          details: error.response.data
            ? String(error.response.data).substring(0, 200)
            : undefined,
        });
        return;
      }

      if (error.request) {
        console.error("요청 전송 실패:", error.request);
        res.status(500).json({
          success: false,
          error: "KOPIS API 서버에 연결할 수 없습니다.",
        });
        return;
      }

      res.status(500).json({
        success: false,
        error: `공연 검색 중 오류가 발생했습니다: ${error.message}`,
      });
    }
  }
);
