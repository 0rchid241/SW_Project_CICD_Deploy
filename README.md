# 서경인사이드 — 커뮤니티 웹 서비스 CI/CD 구축

GitLab CI/CD와 Docker를 활용해 커뮤니티 웹 서비스의 빌드 및 배포 환경을 구성한 팀 프로젝트입니다.

**프로젝트 유형:** SW 전문인재양성 팀 프로젝트  
**담당 분야:** CI/CD 파이프라인 구성, Docker 빌드 환경 설정, 컨테이너 모니터링  
**주요 기술:** GitLab CI/CD, Docker, Docker Compose, Linux, Bash, Nginx

## 프로젝트 소개

서경인사이드는 게시판과 회원 기능을 중심으로 구성된 커뮤니티 웹 서비스입니다.

Spring Boot 백엔드와 React 프론트엔드를 분리하여 개발했으며, 두 애플리케이션을 Docker 이미지로 빌드하고 테스트 및 서비스 환경에서 실행할 수 있도록 배포 인프라를 구성했습니다.

프로젝트에서는 GitLab CI를 이용한 이미지 빌드, Container Registry를 통한 이미지 관리, Docker Compose 기반 실행 환경, Blue/Green 서비스 전환 구조를 다뤘습니다.

## 기술 스택

| 구분 | 기술 | 용도 |
| --- | --- | --- |
| CI/CD | GitLab CI, GitLab Runner | 빌드 및 배포 파이프라인 |
| Container | Docker, Docker Compose | 애플리케이션 및 인프라 실행 |
| Registry | GitLab Container Registry | 이미지 저장 및 관리 |
| Web Server | Nginx | 요청 라우팅 |
| Scripting | Bash | 배포 및 모니터링 |
| Backend | Java, Spring Boot | 서버 애플리케이션 |
| Frontend | React, Vite | 웹 애플리케이션 |
| Data | MySQL, Redis | 데이터 저장 및 서비스 연동 |

## 시스템 아키텍처

```text
           Backend / Frontend
                  │
                  ▼
             GitLab CI
                  │
            Docker 이미지 빌드
                  │
                  ▼
       GitLab Container Registry
                  │
                  ▼
            테스트 환경 배포
                  │
                  ▼
             Docker Compose
                  │
          ┌───────┴───────┐
          ▼               ▼
     Spring Boot        React
          │
     MySQL / Redis


    별도 서비스 환경 전환 스크립트
                  │
                  ▼
          Blue / Green 기동
                  │
             헬스체크
                  │
                  ▼
          Nginx 라우팅 변경
                  │
                  ▼
         이전 컨테이너 종료
```

GitLab CI에는 이미지 빌드 및 테스트 환경 배포 단계가 구성되어 있으며, 서비스 환경의 Blue/Green 전환은 별도 스크립트로 관리합니다.

## 주요 구현 내용

### 1. GitLab CI 기반 Docker 이미지 빌드

GitLab Runner에서 Docker-in-Docker 환경을 사용하여 백엔드와 프론트엔드 이미지를 빌드하도록 구성했습니다.

빌드된 이미지는 GitLab Container Registry에 업로드하며, 브랜치 정보를 이용해 이미지 태그를 관리합니다.

배포 단계에서는 사용할 이미지 정보를 지정하고 Docker Compose를 이용해 테스트 환경의 컨테이너를 실행하도록 구성했습니다.

**관련 파일**

- [backend-ci.yml](backend-ci.yml)
- [frontend-ci.yml](frontend-ci.yml)
- [deploy-compose.yml](deploy-compose.yml)

### 2. Docker Compose 기반 실행 환경

테스트 환경과 서비스 환경을 분리하고 각 환경에서 애플리케이션과 인프라 컨테이너를 실행하도록 구성했습니다.

MySQL, Redis 등의 서비스는 Docker 네트워크를 통해 연결하며, 환경별 설정은 Docker Compose와 환경변수로 관리합니다.

### 3. Blue/Green 서비스 전환

팀에서 구성한 서비스 배포 환경에는 Blue/Green 컨테이너 전환 스크립트가 포함되어 있습니다.

새로운 컨테이너를 실행한 뒤 백엔드 헬스체크를 수행하고, 정상 응답을 확인하면 Nginx 라우팅을 변경하도록 설계했습니다.

헬스체크에 실패하면 신규 컨테이너를 중지하는 분기와 이전 환경의 컨테이너를 종료하는 절차도 포함되어 있습니다.

**관련 파일:** [switching.sh](scripts/switching.sh)

## 개인 담당 역할

### GitLab CI 파이프라인 구성

백엔드 애플리케이션의 Docker 이미지 빌드와 Registry 업로드를 위한 CI 설정 작업을 담당했습니다.

- GitLab Runner 및 Docker 실행 환경 테스트
- Container Registry 로그인 과정 추가
- Docker 이미지 빌드 및 push 명령 구성
- 이미지 태그 환경변수 설정
- 공통 CI 설정의 Docker-in-Docker 서비스 선언 수정

**관련 커밋:** [CI 빌드 및 Registry 업로드 설정](https://github.com/0rchid241/SW_Project_CICD_Backend/commit/30d998bfd49a5cccb3cc4b849f37625f9c128c3a)

### CI 빌드 환경 문제 대응

CI 환경에서 발생할 수 있는 Gradle Wrapper 실행 권한 및 Runner 실행 환경 문제에 대응하기 위해 관련 설정을 변경했습니다.

**Gradle Wrapper 실행 권한**

Docker 이미지 빌드 과정에서 `gradlew`를 실행할 수 있도록 Dockerfile에 실행 권한 부여 명령을 추가했습니다.

```dockerfile
RUN chmod +x gradlew
```

**Runner 아키텍처 설정**

GitLab Runner 태그를 `arm64`에서 `amd64`로 변경하여 빌드 작업의 실행 환경을 조정했습니다.

**Docker-in-Docker 서비스 설정**

CI YAML에서 Docker-in-Docker 서비스를 서비스 목록 구조로 선언하도록 수정했습니다.

이 작업을 통해 CI 파이프라인 실행에 영향을 주는 파일 권한, Runner 아키텍처, Docker 서비스 구성 요소를 다루는 경험을 쌓았습니다.

**관련 커밋:** [Gradle 권한 설정](https://github.com/0rchid241/SW_Project_CICD_Backend/commit/b4d05f073e52309abfe157216b79ff3bcb242c27) · [Runner 설정 변경](https://github.com/0rchid241/SW_Project_CICD_Backend/commit/19d8b15c7c2ec8da561a89a3a4b46b4b75d7e751) · Docker-in-Docker 설정

### Docker 컨테이너 모니터링

테스트 환경의 컨테이너 자원 사용량을 수집하기 위한 Bash 스크립트를 추가했습니다.

`docker stats` 명령을 이용해 컨테이너별 CPU 사용률, 메모리 사용률, 프로세스 수(PIDs)를 주기적으로 수집하고 CSV 형식으로 저장하도록 구현했습니다.

이를 통해 테스트 중 컨테이너의 자원 사용 상태를 시간에 따라 확인할 수 있는 기록 수단을 마련했습니다.

**관련 커밋:** 모니터링 스크립트 구현

### 컨테이너 서비스 연결 설정

Docker Compose 환경에서 서비스 간 연결을 위한 Redis 호스트 설정과 테스트 환경의 HikariCP 연결 풀 설정을 수정했습니다.

**관련 커밋:** Redis 연결 설정 · HikariCP 설정

## 관련 저장소

| 저장소 | 설명 |
| --- | --- |
| [Community Backend](https://github.com/0rchid241/SW_Project_CICD_Backend) | Spring Boot 기반 백엔드 |
| [Community Frontend](https://github.com/0rchid241/SW_Project_CICD_Frontend) | React 기반 프론트엔드 |
| [Community Deploy](https://github.com/0rchid241/SW_Project_CICD_Deploy) | CI/CD 파이프라인 및 배포 인프라 |
