# 서경인사이드 커뮤니티 — CI/CD 및 배포 환경

**SW 전문인재양성 팀 프로젝트 | GitLab CI/CD · Docker · Nginx · Bash**

Spring Boot 기반 백엔드와 React 기반 프론트엔드를 컨테이너 이미지로 빌드하고, 테스트·서비스 환경에 배포하기 위한 구성입니다. 이 저장소는 웹 애플리케이션 자체가 아니라 **빌드 파이프라인, Docker Compose, 배포 스크립트, 프록시 설정**을 담고 있습니다.

## 프로젝트 개요

커뮤니티 웹 서비스를 여러 구성 요소로 개발하면서 빌드와 배포 과정의 일관성을 확보하는 것을 목표로 했습니다.

- **CI:** GitLab CI에서 Docker 이미지를 빌드하고 Container Registry에 업로드
- **테스트 환경:** 빌드한 이미지와 Docker Compose를 이용해 백엔드·프론트엔드 컨테이너 실행
- **서비스 환경:** Blue/Green 컨테이너와 Nginx 라우팅 전환 스크립트 구성
- **관측:** 컨테이너별 CPU·메모리 사용률 등을 기록하는 스크립트 구성

### 기술 구성

| 영역 | 기술 및 역할 |
| --- | --- |
| CI/CD | GitLab CI, GitLab Runner, Container Registry |
| 빌드·실행 | Docker, Docker-in-Docker, Docker Compose |
| 배포·라우팅 | Bash, Nginx, Blue/Green 전환 스크립트 |
| 연동 서비스 | Spring Boot, React, MySQL, Redis |

### 저장소 구성

| 저장소 | 역할 |
| --- | --- |
| [Backend](https://github.com/0rchid241/SW_Project_CICD_Backend) | Spring Boot 애플리케이션 코드와 CI 연결 설정 |
| [Frontend](https://github.com/0rchid241/SW_Project_CICD_Frontend) | React 애플리케이션 코드 |
| **[Deploy](https://github.com/0rchid241/SW_Project_CICD_Deploy)** | CI 설정, 테스트·서비스 환경 구성, 배포 스크립트 |

## 빌드 및 배포 흐름

```text
Backend / Frontend 소스
          │
          ▼
      GitLab CI
          │ Docker 이미지 빌드 및 업로드
          ▼
 GitLab Container Registry
          │
          ▼
  Docker Compose 배포
          │
          ├── 테스트 환경: 최신 이미지 Pull 후 컨테이너 실행
          │
          └── 서비스 환경: Blue / Green 컨테이너 구성
                                  │
                                  └── 별도 전환 스크립트
                                       헬스체크 → Nginx 라우팅 변경
```

위 다이어그램은 **저장소에 구현된 구성 요소의 역할**을 나타냅니다. Blue/Green 전환이 모든 GitLab CI 실행에서 자동 수행된다는 뜻은 아닙니다.

주요 설정 파일은 다음과 같습니다.

- [`backend-ci.yml`](backend-ci.yml) / [`frontend-ci.yml`](frontend-ci.yml): Docker 이미지 빌드와 Registry push
- [`deploy-compose.yml`](deploy-compose.yml): 배포에 사용할 이미지 지정 및 테스트 환경 배포 단계
- [`scripts/deploy.sh`](scripts/deploy.sh): 테스트·서비스 환경별 컨테이너 기동
- [`scripts/switching.sh`](scripts/switching.sh): Blue/Green 컨테이너 기동, 백엔드 헬스체크, Nginx 라우팅 전환
- [`scripts/monitor-docker-stats.sh`](scripts/monitor-docker-stats.sh): 컨테이너 자원 사용량 기록
- [`test-server/`](test-server/) / [`service-server/`](service-server/): 환경별 Compose·Nginx 구성

## 개인 담당 작업

팀이 함께 개발한 프로젝트 중, 아래는 **작성자 `orchid`의 Git 커밋으로 직접 변경을 확인할 수 있는 작업**입니다.

### 1. GitLab CI와 Docker 이미지 빌드 설정

- GitLab Runner에서 Docker 명령을 실행할 수 있도록 CI 설정을 작성·시험했습니다. [Runner 테스트 커밋](https://github.com/0rchid241/SW_Project_CICD_Backend/commit/32faf66c35fb78462eba3b0a98c5560db14cf6d8)
- 백엔드 빌드 작업에 Container Registry 로그인, 이미지 태그 지정, `docker build`, `docker push` 단계를 추가했습니다. [Registry 업로드 설정 커밋](https://github.com/0rchid241/SW_Project_CICD_Backend/commit/30d998bfd49a5cccb3cc4b849f37625f9c128c3a)
- 공통 `backend-ci.yml`에서 Docker-in-Docker 서비스 선언 구조를 수정했습니다. 공통 CI 설정 커밋

### 2. 빌드 환경 문제 대응

- CI Runner 태그를 `arm64`에서 `amd64`로 변경해 빌드 실행 환경 설정을 조정했습니다. [설정 변경 커밋](https://github.com/0rchid241/SW_Project_CICD_Backend/commit/19d8b15c7c2ec8da561a89a3a4b46b4b75d7e751)
- Docker 이미지 빌드 중 Gradle Wrapper 실행 권한을 다루기 위해 Dockerfile에 `chmod +x gradlew`를 추가했습니다. [Dockerfile 수정 커밋](https://github.com/0rchid241/SW_Project_CICD_Backend/commit/b4d05f073e52309abfe157216b79ff3bcb242c27)

### 3. 컨테이너 모니터링 및 실행 환경 설정

- `docker stats` 출력을 주기적으로 수집해 컨테이너별 CPU·메모리 사용률과 프로세스 수(PIDs)를 CSV로 기록하는 스크립트를 추가했습니다. 모니터링 스크립트 커밋
- Docker 환경에서 서비스 간 접속을 위해 Redis 호스트를 컨테이너 서비스 이름으로 지정하고, 테스트 환경의 Hikari 연결 풀 설정을 추가했습니다. Redis 설정 커밋 · Hikari 설정 커밋

## 팀 프로젝트 구현 범위

팀 전체 작업으로는 테스트·서비스 환경 분리, Docker Compose를 이용한 인프라 연결, Blue/Green 컨테이너 전환 및 Nginx 라우팅, 백엔드 헬스체크 로직 등이 포함됩니다. **개인 담당 작업과 팀 전체 구현은 구분해 기술했습니다.**

이 프로젝트는 교육 과정에서 만든 팀 프로젝트이며, 공개된 설정 및 커밋을 기준으로 구현 내용을 소개합니다. 실제 운영 환경의 가동률이나 무중단 배포 성과를 별도로 측정했다고 주장하지 않습니다.
