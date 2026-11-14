# 커뮤니티 웹 서비스 — CI/CD 및 배포 환경

> SW 전문인재양성 팀 프로젝트의 **배포·운영 설정 저장소**입니다. 웹 서비스 전체가 아닌, GitLab CI/CD 설정 및 Docker 기반 실행·배포 스크립트를 담고 있습니다.

## 프로젝트 소개

팀에서 개발한 커뮤니티 웹 서비스의 **Backend(Spring Boot)**와 **Frontend(React)**를 Docker 이미지로 빌드하고 배포하기 위한 환경을 구성했습니다. 본 저장소에는 테스트/서비스 환경용 Docker Compose 설정, GitLab CI 설정 파일, Nginx 라우팅 및 배포 관리 스크립트가 포함되어 있습니다.

- Backend 코드: [SW_Project_CICD_Backend](https://github.com/0rchid241/SW_Project_CICD_Backend)
- Frontend 코드: [SW_Project_CICD_Frontend](https://github.com/0rchid241/SW_Project_CICD_Frontend)
- Deploy 설정(현재 저장소): [SW_Project_CICD_Deploy](https://github.com/0rchid241/SW_Project_CICD_Deploy)

> 이 저장소는 원래 팀의 GitLab 프로젝트를 GitHub로 이전한 자료입니다. GitHub 저장소 소유와 **개별 코드 작성자**는 구분해야 합니다.

## 시스템 구성 (저장소의 설정 파일 기준)

```text
GitLab CI
  ├─ backend-ci.yml  ─ Docker 이미지 빌드 → Registry push
  └─ frontend-ci.yml ─ Docker 이미지 빌드 → Registry push
                                  │
                                  ▼
                         Docker Compose
                         ├─ 테스트 환경
                         └─ 서비스 환경
                             ├─ Blue/Green 컨테이너
                             └─ Nginx 라우팅 전환
```

- [backend-ci.yml](backend-ci.yml), [frontend-ci.yml](frontend-ci.yml): Docker-in-Docker를 이용한 이미지 빌드 및 Registry 업로드 설정
- [scripts/deploy.sh](scripts/deploy.sh): 테스트/서비스 환경별 컨테이너 실행
- [scripts/switching.sh](scripts/switching.sh): 대체 Blue/Green 컨테이너 기동, 백엔드 헬스체크, Nginx 라우팅 변경 등의 절차
- [test-server/](test-server/), [service-server/](service-server/): 환경별 Docker Compose 및 인프라 설정

위 내용은 **저장소 코드에 구현된 흐름**을 설명한 것으로, 현시점 운영 상태 또는 모든 환경에서의 성공적인 배포를 보증하지 않습니다.

## 나의 기여 — Git 기록에서 확인된 부분

아래 항목은 Git 작성자 `orchid`로 남아 있는 변경 파일 및 커밋을 근거로 정리했습니다.

| 영역 | 직접 변경한 내용 | 근거 |
| --- | --- | --- |
| CI 기반 환경 확인 | GitLab Runner/Docker 연결 테스트를 위한 CI 설정 추가·수정 | [커밋](https://github.com/0rchid241/SW_Project_CICD_Backend/commit/32faf66c35fb78462eba3b0a98c5560db14cf6d8) |
| 이미지 빌드·배포 파이프라인 | 백엔드 Docker 이미지 빌드와 Container Registry push를 위한 CI 설정 작성·수정 | [커밋](https://github.com/0rchid241/SW_Project_CICD_Backend/commit/30d998bfd49a5cccb3cc4b849f37625f9c128c3a) |
| 빌드 문제 대응 | Gradle 실행 권한 문제에 대응하기 위한 Dockerfile 변경, CI 설정 보완 | [커밋](https://github.com/0rchid241/SW_Project_CICD_Backend/commit/b4d05f073e52309abfe157216b79ff3bcb242c27) |
| 공통 배포 CI 연결 | 배포 저장소의 `backend-ci.yml` 수정 | 커밋 |
| 모니터링 | Docker 컨테이너 CPU 사용량 점검 스크립트 추가 | 커밋 |
| 환경변수·연결 설정 | 서비스 Redis 접속 주소 및 테스트 Hikari 설정 수정 | Redis 커밋 · Hikari 커밋 |

커밋 작성자 기록만으로 공동 작업의 정확한 기여 비율을 확정할 수는 없으므로, 위에는 **직접 변경이 확인된 작업**만 기재했습니다.

## 팀 전체 구현과 개인 기여의 구분

Blue/Green 트래픽 스위칭, 헬스체크, Nginx 재설정 등은 이 저장소에 구현되어 있으나, 일부 주요 스크립트 변경은 **다른 팀원 계정**으로 기록되어 있습니다. 해당 기능은 팀 프로젝트의 구현 내용으로 소개하되, 개인이 전부 작성했다고 표기하지 않습니다.

또한 JWT·소셜 로그인·게시판 API와 관련된 개인 기여는 현재 확인한 GitHub 이력만으로 확정되지 않았습니다. 원본 GitLab 브랜치/커밋 또는 다른 증빙을 확인한 뒤 기재하겠습니다.

## 포트폴리오 보완 예정 사항

- [ ] GitLab 원본 기록의 개인별 기여 범위 및 이력 검증
- [ ] 교육 기간·팀 구성·실습 범위 확인
- [ ] 실제 CI 파이프라인 성공 화면 또는 데모 증빙(가능한 경우)
- [ ] 기술 선택 이유, 배포 오류와 해결 과정 구체화
- [ ] 필요한 경우 재현 가능한 로컬 실행 안내 및 비밀정보 점검

> **참고:** 이 README는 취업 포트폴리오를 위한 기록 정리 초안입니다. 외부에 공개하면 안 되는 키, 비밀번호, 내부 서버 주소 등은 추가하지 않습니다.
