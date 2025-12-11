# My Registration API

Rails 7 기반의 시험/강의 등록 및 결제 관리 API 서버

### 프로젝트 개요

시험(Test)과 강의(Course) 등록, 결제 처리, 그리고 자동화된 알림 및 상태 관리를 제공하는 RESTful API 서버

### 핵심 기능

- JWT 기반 사용자 인증
- 시험/강의 등록 및 관리
-  결제 처리
-  스케줄러 기반 자동화 (Cron + Polling)
  - Cron기반 결제 처리 이메일 알림
  - Polling기반 Test Satus 변경
-  Soft Delete 지원
-  Swagger API 문서


## 프로젝트 구조
```
my-registration-api/
├── app/
│   ├── controllers/
│   │   ├── concerns/
│   │   │   ├── authenticable.rb       # JWT 인증
│   │   │   └── payable.rb             # Polymorphic 결제 신청
│   │   ├── auth/
│   │   │   └── sessions_controller.rb # 로그인/로그아웃
│   │   ├── users_controller.rb
│   │   ├── tests_controller.rb
│   │   ├── courses_controller.rb
│   │   └── payments_controller.rb
│   │
│   ├── models/
│   │   ├── concerns/
│   │   │   └── soft_deletable.rb      # Soft Delete
│   │   ├── user.rb
│   │   ├── test.rb
│   │   ├── course.rb
│   │   └── payment.rb
│   │
│   ├── services/
│   │   ├── payment_reminder_service.rb       # Cron - 5일 전 알림
│   │   └── test_status_polling_service.rb    # Polling - Test 상태 변경
│   │
│   ├── serializers/
│   │   ├── user_serializer.rb
│   │   ├── test_serializer.rb
│   │   ├── course_serializer.rb
│   │   └── payment_serializer.rb
│   │
│   ├── validators/
│   │
│   ├── mailers/
│   │   └── payment_reminder_mailer.rb
│   │
│   └── views/
│       └── payment_reminder_mailer/
│           ├── pending_payment_reminder.html.erb
│           └── pending_payment_reminder.text.erb
│
├── config/
│   ├── initializers/
│   │   └── scheduler.rb               # Rufus-Scheduler 설정
│   ├── routes.rb
│   └── application.rb
│
├── lib/
│   └── json_web_token.rb              # JWT 헬퍼
│
├── spec/
│   └── requests/                      # Swagger Spec
│       ├── auth_spec.rb
│       ├── users_spec.rb
│       ├── tests_spec.rb
│       ├── courses_spec.rb
│       └── payments_spec.rb
│
├── docker-compose.yml
├── Dockerfile.dev
└── Gemfile
```
## API 문서

### Swagger UI

서버 실행 후 다음 URL에서 API 문서 확인:
```
http://localhost:3000/api-docs
```

### Rufus-Scheduler 설정

```ruby
# config/initializers/scheduler.rb
scheduler = Rufus::Scheduler.new
```

#### Cron: 매일 오전 9시 (KST)
scheduler.cron '0 9 * * * Asia/Seoul' do
  PaymentReminderService.check_and_send_reminders
end

### 1. Test Status Update (Cron)

**실행 주기:** 매일 오전 9시 (KST)

**동작:**
1. Course/Test가 시작 5일 이내인 경우
2. 해당 Test/Course에 등록된 결제가 이루어지지 않은 경우
3. 결제를 해야하는 User에게 메일 발송

**코드:**

```ruby
# app/services/test_status_polling_service.rb
TestStatusPollingService.update_test_statuses
```

#### 메일 확인 (Letter Opener)

개발 환경에서 발송된 이메일 확인:
```
http://localhost:3000/letter_opener
```

### 2. Test Status Update (Polling)

**실행 주기:** 1분마다

**동작:**

1. `start_at` 시간이 지난 Test → `AVAILABLE` → `IN_PROGRESS`
2. `end_at` 시간이 지난 Test → `IN_PROGRESS` → `COMPLETED`

**코드:**

```ruby
# app/services/test_status_polling_service.rb
TestStatusPollingService.update_test_statuses
```

### How to run
```
1. 저장소 클론
git clone <repository-url>
cd my-registration-api

2. Docker 컨테이너 빌드 및 실행
docker-compose up -d

3. 데이터베이스 생성 및 마이그레이션
docker-compose exec web rails db:create
docker-compose exec web rails db:migrate

4. 서버 확인
curl http://localhost:3000
```
