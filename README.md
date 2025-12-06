# 🏨 Hotel Booking Platform - Complete Microservices Architecture

## 📋 Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Services](#services)
4. [Quick Start](#quick-start)
5. [API Documentation](#api-documentation)
6. [Database Schema](#database-schema)
7. [Event Flow](#event-flow)
8. [Deployment](#deployment)
9. [Monitoring](#monitoring)
10. [Security](#security)
11. [Performance](#performance)
12. [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

A production-ready hotel booking platform built with microservices architecture featuring:
- **10 Microservices** with independent databases
- **Event-driven architecture** using Redis
- **Full-text search** with Elasticsearch
- **Payment processing** (Stripe + PayPal)
- **Image processing** with Cloudinary
- **Real-time analytics**
- **Kubernetes-ready** deployment

### Technology Stack

```
Frontend:     React + TypeScript + Tailwind CSS
Backend:      NestJS + TypeScript
Database:     PostgreSQL (per service)
Cache/Queue:  Redis + BullMQ
Search:       Elasticsearch 8.x
Payments:     Stripe + PayPal
Storage:      Cloudinary
Auth:         JWT + Passport.js
Container:    Docker + Kubernetes
CI/CD:        GitHub Actions
Monitoring:   Grafana + Prometheus (optional)
```

---

## 🏗️ Architecture

### Service Architecture

```

                    ┌──────────────────┐
                    │   React Client   │
                    └────────┬─────────┘
                             │
                    ┌────────▼─────────┐
                    │   API Gateway    │ ← Rate Limiting, Auth
                    │   Port: 3000     │
                    └────────┬─────────┘
                             │
            ┌────────────────┼────────────────┐
            │                │                │
    ┌───────▼────┐   ┌──────▼──────┐  ┌─────▼──────┐
    │   Auth     │   │   Hotels    │  │  Bookings  │
    │   :3001    │   │   :3002     │  │   :3003    │
    └────────────┘   └─────────────┘  └────────────┘
                             │
            ┌────────────────┼────────────────┐
            │                │                │
    ┌───────▼────┐   ┌──────▼──────┐  ┌─────▼──────┐
    │  Payments  │   │   Search    │  │  Reviews   │
    │   :3004    │   │   :3005     │  │   :3008    │
    └────────────┘   └─────────────┘  └────────────┘
                             │
            ┌────────────────┼────────────────┐
            │                │                │
    ┌───────▼────┐   ┌──────▼──────┐  ┌─────▼──────┐
    │Notifications│  │   Worker    │  │ Analytics  │
    │   :3006    │   │   :3007     │  │   :3009    │
    └────────────┘   └─────────────┘  └────────────┘
                             │
    ┌────────────────────────┼────────────────────┐
    │                        │                    │
┌───▼────┐          ┌────────▼───┐      ┌────────▼────┐
│Postgres│          │   Redis    │      │Elasticsearch│
│ :5432  │          │   :6379    │      │   :9200     │
└────────┘          └────────────┘      └─────────────┘
```

### Database Per Service Pattern

Each microservice has its own database for:
- **Data isolation** and autonomy
- **Independent scaling**
- **Technology flexibility**
- **Fault isolation**

---

## 🎯 Services
# All  microservices and their ports:

API Gateway          → Port 3000  (Main entry point)
Auth Service         → Port 3001  (Login/Register)
Hotels Service       → Port 3002  (Hotels & Rooms)
Bookings Service     → Port 3003  (Reservations)
Payments Service     → Port 3004  (Stripe/PayPal)
Search Service       → Port 3005  (Elasticsearch)
Notifications Service → Port 3006  (Email/SMS)
Worker Service       → Port 3007  (Background jobs)
Reviews Service      → Port 3008  (User reviews)
Analytics Service    → Port 3009  (Reports)
Chat Service         → Port 3010  (Live chat)
Currency Service     → Port 3011  (Exchange rates)
Loyalty Service      → Port 3012  (Points/Rewards)

### 1. API Gateway (Port 3000)
**Purpose**: Single entry point for all client requests

**Features**:
- Request routing and proxying
- JWT authentication validation
- Rate limiting (100 req/min)
- Request/response logging
- Health checks

**Routes**:
```
POST   /api/auth/register
POST   /api/auth/login
GET    /api/hotels
POST   /api/hotels
GET    /api/bookings
POST   /api/payments
GET    /api/search/hotels
```

---

### 2. Auth Service (Port 3001)
**Purpose**: User authentication and authorization

**Database**: `auth_db`
- Users table (id, email, password, role, etc.)

**Features**:
- User registration with password hashing (bcrypt)
- JWT token generation and validation
- Role-based access (USER, AGENT, ADMIN)
- Passport.js strategies

**API Endpoints**:
```
POST   /api/auth/register     - Register new user
POST   /api/auth/login        - Login and get JWT
GET    /api/auth/me           - Get current user
PATCH  /api/auth/profile      - Update profile
```

---

### 3. Hotels Service (Port 3002)
**Purpose**: Hotel and room management

**Database**: `hotels_db`
- Hotels table
- Rooms table (with foreign key to hotels)

**Features**:
- CRUD operations for hotels and rooms
- Image upload to Cloudinary
- Redis event emission (for search indexing)
- Room availability tracking
- Amenities management

**API Endpoints**:
```
POST   /api/hotels            - Create hotel
GET    /api/hotels            - List hotels (with filters)
GET    /api/hotels/:id        - Get hotel details
PATCH  /api/hotels/:id        - Update hotel
DELETE /api/hotels/:id        - Delete hotel
POST   /api/upload/hotel/:id  - Upload hotel image
```

---

### 4. Bookings Service (Port 3003)
**Purpose**: Reservation management

**Database**: `bookings_db`
- Bookings table (id, userId, hotelId, roomId, dates, status)

**Features**:
- Create and manage bookings
- Availability checking (prevents double-booking)
- Booking status management (PENDING, CONFIRMED, CANCELLED)
- Redis queue for payment processing
- Transaction management with Prisma

**API Endpoints**:
```
POST   /api/bookings          - Create booking
GET    /api/bookings          - List bookings
GET    /api/bookings/:id      - Get booking details
PATCH  /api/bookings/:id      - Update booking status
DELETE /api/bookings/:id      - Cancel booking
```

---

### 5. Payments Service (Port 3004)
**Purpose**: Payment processing

**Database**: `payments_db`
- Payments table (id, bookingId, amount, status, provider)

**Features**:
- **Stripe integration** with Payment Intents
- **PayPal integration** with order creation
- Webhook handling for payment events
- Payment status tracking
- Refund processing

**API Endpoints**:
```
POST   /api/payments              - Create payment intent
GET    /api/payments/:id          - Get payment details
POST   /api/payments/webhook/stripe - Stripe webhook
POST   /api/paypal/create-order   - Create PayPal order
POST   /api/paypal/capture-order  - Capture PayPal payment
```

**Stripe Flow**:
1. Client requests payment → Creates Payment Intent
2. Client completes payment on frontend
3. Stripe sends webhook → Updates booking status
4. Notification sent to user

---

### 6. Search Service (Port 3005)
**Purpose**: Full-text search with Elasticsearch

**Features**:
- Hotel search with filters (city, country, rating, amenities)
- Fuzzy matching and relevance scoring
- Auto-complete suggestions
- Search result ranking by rating
- Real-time indexing via Redis events

**API Endpoints**:
```
GET    /api/search/hotels        - Search hotels
GET    /api/search/suggestions   - Get autocomplete
POST   /api/index/hotels         - Index hotel (internal)
POST   /api/index/rebuild        - Rebuild entire index
```

**Search Query Example**:
```bash
GET /api/search/hotels?q=luxury&city=Paris&minRating=4&amenities=Pool,WiFi
```

---

### 7. Notifications Service (Port 3006)
**Purpose**: Email and SMS notifications

**Features**:
- Booking confirmation emails
- Payment success notifications
- Cancellation notifications
- Redis queue consumer
- SMTP integration (Nodemailer)

**Events Handled**:
- `booking.created` → Send confirmation
- `booking.confirmed` → Send payment success
- `booking.cancelled` → Send cancellation notice

---

### 8. Worker Service (Port 3007)
**Purpose**: Background job processing

**Features**:
- **Image optimization** (Sharp library)
- Multiple image sizes (thumbnail, medium, large)
- Cloudinary upload
- Scheduled tasks (cleanup, sync)
- Bulk operations

**Jobs**:
```
optimize-hotel-image    - Process hotel images
optimize-room-image     - Process room images
sync-to-elasticsearch   - Sync data to search
cleanup-expired         - Remove old data
```

**Cron Jobs**:
- Daily at 2 AM: Clean expired bookings
- Hourly: Update hotel ratings
- Every 6 hours: Sync search index

---

### 9. Reviews Service (Port 3008)
**Purpose**: User reviews and ratings

**Database**: `reviews_db`
- Reviews table (id, userId, hotelId, rating, comment)

**Features**:
- Create and manage reviews
- Rating statistics (average, distribution)
- Helpful votes on reviews
- Hotel owner responses
- Verified purchases only

**API Endpoints**:
```
POST   /api/reviews                   - Create review
GET    /api/reviews/hotel/:id         - Get hotel reviews
GET    /api/reviews/hotel/:id/stats   - Get rating stats
PATCH  /api/reviews/:id/helpful       - Mark helpful
PATCH  /api/reviews/:id/response      - Add owner response
```

---

### 10. Analytics Service (Port 3009)
**Purpose**: Business intelligence and reporting

**Features**:
- Dashboard metrics (revenue, bookings, occupancy)
- Hotel performance scoring
- Booking trends analysis
- Popular destinations
- Revenue reports

**API Endpoints**:
```
GET    /api/analytics/dashboard            - Overview metrics
GET    /api/analytics/revenue              - Revenue reports
GET    /api/analytics/occupancy            - Occupancy rates
GET    /api/analytics/hotel/:id/performance - Hotel metrics
GET    /api/analytics/popular-destinations - Top cities
GET    /api/analytics/booking-trends       - Trend analysis
```

---

## 🚀 Quick Start

### Prerequisites
```bash
# Required
Node.js 18+
Docker & Docker Compose
pnpm (recommended)

# Optional for development
PostgreSQL client
Redis client
Elasticsearch head plugin
```

### Installation

#### Option 1: Automated Setup (Recommended)
```bash
# Clone repository
git clone <repo-url>
cd hotel-booking-platform

# One-command setup
make setup

# Start all services
pnpm run dev
```
---

## 📖 API Documentation

### Authentication

All protected endpoints require JWT token:

```bash
# Login to get token
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@test.com",
    "password": "User123!"
  }'

# Response
{
  "user": { ... },
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}

# Use token in subsequent requests
curl -X GET http://localhost:3000/api/bookings \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Common Workflows

#### 1. Search and Book Hotel

```bash
# Step 1: Search for hotels
GET /api/search/hotels?city=Paris&minRating=4

# Step 2: Get hotel details
GET /api/hotels/HOTEL_ID

# Step 3: Create booking
POST /api/bookings
{
  "userId": "USER_ID",
  "hotelId": "HOTEL_ID",
  "roomId": "ROOM_ID",
  "checkIn": "2025-12-01",
  "checkOut": "2025-12-05",
  "guests": 2,
  "totalPrice": 1000
}

# Step 4: Create payment
POST /api/payments
{
  "bookingId": "BOOKING_ID",
  "userId": "USER_ID",
  "amount": 1000,
  "provider": "stripe",
  "currency": "USD"
}

# Step 5: Complete payment on frontend using clientSecret
# Step 6: Receive confirmation email
```

#### 2. Leave Review

```bash
# After checkout, leave review
POST /api/reviews
{
  "userId": "USER_ID",
  "hotelId": "HOTEL_ID",
  "bookingId": "BOOKING_ID",
  "rating": 5,
  "title": "Amazing stay!",
  "comment": "Everything was perfect..."
}
```

---

## 💾 Database Schema

### Auth Service Schema
```prisma
model User {
  id        String   @id @default(uuid())
  email     String   @unique
  password  String
  firstName String
  lastName  String
  role      UserRole @default(USER)
  isActive  Boolean  @default(true)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

enum UserRole {
  USER
  AGENT
  ADMIN
}
```

### Hotels Service Schema
```prisma
model Hotel {
  id          String   @id @default(uuid())
  name        String
  description String
  city        String
  country     String
  rating      Float    @default(0)
  amenities   String[]
  rooms       Room[]
}

model Room {
  id            String   @id @default(uuid())
  hotelId       String
  name          String
  type          RoomType
  pricePerNight Float
  capacity      Int
  amenities     String[]
  hotel         Hotel    @relation(fields: [hotelId], references: [id])
}
```

### Bookings Service Schema
```prisma
model Booking {
  id         String        @id @default(uuid())
  userId     String
  hotelId    String
  roomId     String
  checkIn    DateTime
  checkOut   DateTime
  status     BookingStatus @default(PENDING)
  totalPrice Float
}

enum BookingStatus {
  PENDING
  CONFIRMED
  CANCELLED
  COMPLETED
}
```

---

## 🔄 Event Flow

### Hotel Update Event
```
Hotels Service
    ↓ (emit event)
Redis Queue: "hotel-events"
    ↓ (consume)
Search Service
    ↓ (index)
Elasticsearch
```

### Booking Creation Event
```
Bookings Service
    ↓ (emit "booking.created")
Redis Queue: "booking-events"
    ├→ Payments Service (process payment)
    └→ Notifications Service (send email)
```

### Image Upload Event
```
Hotels Service (upload)
    ↓ (emit event)
Redis Queue: "image-processing"
    ↓ (consume)
Worker Service
    ├→ Resize images
    ├→ Optimize quality
    └→ Upload to Cloudinary
```

---

### Environment Variables

Critical environment variables to configure:

**Stripe** (Payments Service):
```
STRIPE_SECRET_KEY=sk_test_your_key
STRIPE_WEBHOOK_SECRET=whsec_your_secret
```

**PayPal** (Payments Service):
```
PAYPAL_CLIENT_ID=your_client_id
PAYPAL_CLIENT_SECRET=your_client_secret
```

**Cloudinary** (Hotels/Worker Service):
```
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
```

**SMTP** (Notifications Service):
```
SMTP_HOST=smtp.gmail.com
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password
```

---

## 📊 Monitoring

### Health Checks

All services expose health endpoints:
```
GET /health       - Overall health
GET /health/live  - Liveness probe
GET /health/ready - Readiness probe
```

### Logging

Centralized logging with structured logs:
```javascript
// Example log format
{
  "level": "info",
  "service": "auth-service",
  "timestamp": "2025-01-15T10:30:00Z",
  "message": "User logged in",
  "userId": "user-123"
}
```

### Metrics (Optional with Prometheus)

Key metrics to monitor:
- Request rate per service
- Response time (p50, p95, p99)
- Error rate
- Database connection pool
- Redis queue size
- Cache hit rate

---

## 🔒 Security

### Implemented Security Measures

1. **Authentication**:
   - JWT tokens with expiration
   - Bcrypt password hashing (10 rounds)
   - HTTP-only cookies option

2. **Authorization**:
   - Role-based access control (RBAC)
   - Service-to-service authentication

3. **API Protection**:
   - Rate limiting (100 req/min)
   - Helmet.js security headers
   - CORS configuration
   - Input validation (class-validator)

4. **Data Protection**:
   - Prisma ORM (SQL injection prevention)
   - Environment variable secrets
   - TLS/SSL in production

5. **Payment Security**:
   - PCI compliance (Stripe handles cards)
   - Webhook signature verification
   - Idempotency keys

---

## ⚡ Performance Optimization

### Caching Strategy
```
Redis Cache:
  - Session data (TTL: 24h)
  - Hotel listings (TTL: 1h)
  - Search results (TTL: 30min)
  - User profiles (TTL: 1h)
```

### Database Optimization
- Indexes on frequently queried fields
- Connection pooling (Prisma)
- Read replicas for heavy queries
- Pagination on list endpoints

### Search Optimization
- Elasticsearch for fast full-text search
- Fuzzy matching with autocomplete
- Result caching
- Index optimization

---

## 🔧 Troubleshooting

### Common Issues

#### 1. Port Already in Use
```bash
# Find and kill process
lsof -ti:3000 | xargs kill -9
```

#### 2. Database Connection Failed
```bash
# Check if PostgreSQL is running
docker-compose ps postgres

# Restart PostgreSQL
docker-compose restart postgres

# Check logs
docker-compose logs postgres
```

#### 3. Redis Connection Timeout
```bash
# Check Redis
docker-compose ps redis

# Test connection
docker exec -it hotel-redis redis-cli ping
```

#### 4. Elasticsearch Not Starting
```bash
# Increase Docker memory to 4GB minimum
# Check logs
docker-compose logs elasticsearch

# Verify health
curl http://localhost:9200/_cluster/health
```

#### 5. Prisma Migration Failed
```bash
# Reset database (⚠️ destroys data)
pnpm --filter auth-service prisma migrate reset

# Or force migration
pnpm --filter auth-service prisma migrate deploy --force
```

---

## 📚 Additional Resources

- [NestJS Documentation](https://docs.nestjs.com)
- [Prisma Documentation](https://www.prisma.io/docs)
- [Stripe API Reference](https://stripe.com/docs/api)
- [Elasticsearch Guide](https://www.elastic.co/guide)
- [Docker Documentation](https://docs.docker.com)
- [Kubernetes Documentation](https://kubernetes.io/docs)

---

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open Pull Request

### Code Standards
- Follow ESLint configuration
- Write unit tests for new features
- Update API documentation
- Follow conventional commits

---

## 📄 License

MIT License - feel free to use this project for learning or commercial purposes.


**Built with ❤️ using NestJS, TypeScript, and modern microservices architecture**
