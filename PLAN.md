# PLAN

MSA 인증 시스템 학습 프로젝트. 메인 산출물 = 인증 서버.

## 진행 방식

단계마다: ① Claude가 내용 설명 → ② Claude가 스캐폴드/주석 추가 → ③ 사용자가 구현 → ④ Claude가 리뷰.
단계는 굵게 유지하고, 각 단계 시작 시 분량 크면 즉석에서 쪼갠다 (예: 2a/2b).

## 확정된 결정

| # | 결정 | 선택 | 비고 |
|---|------|------|------|
| 1 | 구현 수준 | Spring Authorization Server | 회사라면 직접 구현 안 함 — 표준 구현체 + 커스터마이징이 상용 관행 |
| 2 | 시나리오 1 클라이언트 | React 데모 SPA (Claude 구현) | Authorization Code + PKCE. 로그인 페이지는 인증서버가 제공 |
| 3 | 토큰 | JWT (RSA 서명) + JWKS 로컬 검증 | 게이트웨이/리소스서버는 요청마다 인증서버 호출 안 함 |
| 4 | SPA 토큰 보관 | 액세스토큰 메모리 + refresh rotation | localStorage 금지 (XSS) |
| 5 | DB | MySQL 8 + docker-compose + Flyway | 회사 스택 이전성 |
| 6 | 사용자 | end-user, 가입 API(BCrypt) + Google 페더레이션 | 페더레이션 = 인증서버가 구글의 클라이언트. 내부 유통 토큰은 항상 자체 발급분 |
| 7 | 리포 구조 | 모노레포 + 서비스별 독립 프로젝트 | |
| 8 | 게이트웨이 | Spring Cloud Gateway WebMVC | 전 서버 가상스레드 on (Java 25) |
| 9 | 신뢰 모델 | 하이브리드 | order-service = zero-trust(JWT 재검증), catalog-service = edge검증 + 헤더주입(strip 필수) — 두 패턴 비교 학습 목적 |

## 기술 스택 / 디폴트

- Spring Boot 4.x, Java 25, Gradle
- 서비스: `auth-server`(:9000), `order-service`(:8081), `catalog-service`(:8082), `gateway`(:8080), `webfront`(:5173)
- issuer: `http://localhost:9000`
- 토큰 수명: access 10분, refresh 24시간 (rotation)

## 커리큘럼

### 시나리오 1 — SPA 로그인 + 백엔드 호출

- [x] **0. 셋업** — 모노레포 구조, docker-compose(MySQL), auth-server 프로젝트 기동
- [ ] **1. 인증서버 기동** — SAS 최소 설정, in-memory 사용자/클라이언트, Authorization Code 플로우 브라우저 관찰 (`/.well-known/*`, JWKS)
- [ ] **2. 사용자 도메인** — users 테이블(Flyway), UserDetailsService 직접 구현, BCrypt, 가입 API
- [ ] **3. 영속화 + 토큰 커스터마이징** — RegisteredClient/Authorization JDBC 저장, JWT 클레임, 토큰 수명, refresh rotation
- [ ] **4. React SPA + CORS** — SPA는 Claude 구현, 사용자는 CORS·클라이언트 등록 대응
- [ ] **5. order-service** — JWT 검증 리소스서버, 보호 API → 시나리오 1 E2E
- [ ] **6. Google 페더레이션** — oauth2Login, 계정 연결 정책 (미결: 동일 이메일 연결 vs 별도 계정)

### 시나리오 2 — APIGateway 경유

- [ ] **7. gateway + catalog-service** — SCG WebMVC 라우팅, order-service는 JWT 릴레이 재검증, catalog-service는 헤더 주입(외부 헤더 strip 포함)
- [ ] **8. (선택 심화)** — 로그아웃/토큰 폐기, 키 롤테이션
