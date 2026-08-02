package com.example.authserver.config;

import org.springframework.context.annotation.Configuration;

/**
 * 1단계: 인증서버 명시적 설정.
 *
 * 참고 문서: https://docs.spring.io/spring-authorization-server/reference/getting-started.html
 * (Defining Required Components 섹션의 구조를 따르되, 직접 작성할 것)
 */
@Configuration
public class SecurityConfig {

    // TODO 1: 인증서버 전용 SecurityFilterChain 빈. @Bean + @Order(1)
    //  - OAuth2AuthorizationServerConfigurer.authorizationServer() 로 configurer 생성
    //  - http.securityMatcher(configurer.getEndpointsMatcher()) → 이 체인은 OAuth2 프로토콜
    //    엔드포인트에만 적용됨 (체인 2개 분리의 핵심)
    //  - .with(configurer, as -> as.oidc(...)) 로 OIDC 활성화 (/.well-known/openid-configuration)
    //  - authorizeHttpRequests: anyRequest().authenticated()
    //  - exceptionHandling: 미인증 HTML 요청은 LoginUrlAuthenticationEntryPoint 로 /login 리다이렉트
    //    (MediaTypeRequestMatcher(MediaType.TEXT_HTML) 조합)

    // TODO 2: 기본 SecurityFilterChain 빈. @Bean + @Order(2)
    //  - OAuth2 엔드포인트 외 나머지 전부 담당 (로그인 페이지 등)
    //  - formLogin 활성화, anyRequest().authenticated()

    // TODO 3: UserDetailsService 빈 — in-memory 테스트 계정 1개.
    //  - InMemoryUserDetailsManager 사용
    //  - 비밀번호는 반드시 PasswordEncoder 로 인코딩해서 저장 (평문/{noop} 금지)
    //  - 2단계에서 DB 기반 구현으로 교체될 예정

    // TODO 4: PasswordEncoder 빈 — BCrypt.

    // TODO 5: RegisteredClientRepository 빈 — SPA 클라이언트 등록 (in-memory).
    //  - InMemoryRegisteredClientRepository 사용
    //  - clientId: "webfront"
    //  - public client 라서 시크릿 없음 → clientAuthenticationMethod = NONE
    //  - authorizationGrantTypes: AUTHORIZATION_CODE + REFRESH_TOKEN
    //  - redirectUri: "http://localhost:5173/callback" (와일드카드 불가, 정확 매칭)
    //  - scopes: "openid", "profile"
    //  - clientSettings: requireProofKey(true) ← PKCE 강제. public client 핵심 방어선
}
