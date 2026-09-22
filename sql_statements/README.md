# SQL 공부 노트 (sql_statements)

이 폴더의 `.sql` 파일에 연습한 쿼리를 모으고, 배운 개념은 이 파일에 정리한다.

## 파일

| 파일 | 대상 DB | 내용 |
|---|---|---|
| `example.sql` | dvdrental | `search_path` 설정과 `SELECT` 기본 예제 |
| `dvdrental_select.sql` | dvdrental | `SELECT` 심화: ORDER BY, WHERE, LIMIT, DISTINCT, BETWEEN, IN, LIKE/ILIKE |
| `company_hr_practice.sql` | company | 스키마 만들기 연습: `CREATE SCHEMA`, `CREATE TABLE`, `INSERT` |

---

## dvdrental_select.sql — SELECT 심화 연습

`dvdrental` DB, `dvdrental.film` / `dvdrental.actor` 테이블로 연습.

| 절/키워드 | 내용 |
|---|---|
| `ORDER BY` | 정렬. `DESC`로 내림차순 |
| `WHERE` | 조건으로 행 필터링 (`length > 100` 등) |
| `LIMIT` | 결과 행 개수 제한 |
| `DISTINCT` | 중복 제거 |
| `BETWEEN a AND b` | `>= a AND <= b`와 동일 |
| `IN (...)` | 여러 값 중 하나와 일치하는지 |
| `LIKE` | 패턴 매칭, `%`는 임의 문자열. 대소문자 **구분함** |
| `ILIKE` | `LIKE`와 같지만 대소문자 **구분 안 함** (PostgreSQL 전용) |

- 테이블명 앞에 `dvdrental.`을 붙이거나, 파일 맨 위 `SET search_path TO dvdrental;`로 생략 가능 (자세한 건 위 "스키마와 search_path" 참고).

---

## company_hr_practice.sql — 스키마/테이블 생성 연습

`company` DB에서 새 스키마와 테이블을 처음부터 만들어보는 연습.

```sql
CREATE SCHEMA hr;
SET search_path TO hr;

CREATE TABLE hr.employees (
    id SERIAL PRIMARY KEY,
    name TEXT,
    position TEXT
);

INSERT INTO hr.employees (name, position)
VALUES ('Alice', 'Manager');

SELECT * FROM hr.employees;
```

- `CREATE SCHEMA hr;`: `company` DB 안에 `hr`이라는 새 스키마(폴더) 생성
- `CREATE TABLE hr.employees (...)`: `hr` 스키마 안에 테이블 생성. `SERIAL PRIMARY KEY`는 자동 증가하는 기본키
- `INSERT INTO ... VALUES (...)`: 행 삽입
- 스키마/테이블 이름 오타(`employee` vs `employees`) 때문에 `relation does not exist` 에러가 났던 적 있음 → 이름은 항상 정확히 일치해야 함

---

## 스키마(schema)와 search_path

### 스키마
- DB 안의 **폴더** 같은 것. 테이블이 스키마 안에 들어 있다.
- `dvdrental` DB에는 `dvdrental`과 `public` 스키마가 있고, 테이블 15개는 `dvdrental` 스키마 안에 있다.

### search_path
- 테이블 이름만 썼을 때 **어느 스키마를 어떤 순서로 찾을지** 정하는 검색 경로.
- 기본값은 `"$user", public`이라서 `dvdrental` 스키마는 보지 않는다. 그래서 설정 없이 `actor`만 쓰면 아래 오류가 난다.
  ```
  ERROR: relation "actor" does not exist
  ```

### 확인하기
```sql
SHOW search_path;
```

### 설정하는 방법 세 가지

```sql
-- 1. 접속(세션) 동안만 적용
SET search_path TO dvdrental;
SELECT * FROM actor;
```

```sql
-- 2. 스키마를 직접 붙이기 (그 쿼리에만 적용)
SELECT * FROM dvdrental.actor;
```

```sql
-- 3. DB의 기본값 바꾸기 (앞으로 새로 여는 접속부터 적용)
ALTER DATABASE dvdrental SET search_path TO dvdrental;
```

| 방법 | 적용 범위 |
|---|---|
| `SET search_path` | 그 접속이 열려 있는 동안 |
| `스키마.테이블` | 그 쿼리 하나 |
| `ALTER DATABASE ... SET` | 이후 새로 여는 모든 접속 |

- 접속은 도구마다 따로다. pgAdmin 탭에서 `SET`을 실행해도 VS Code(SQLTools) 접속에는 적용되지 않는다.

---

## SELECT 기본

```sql
SELECT * FROM actor;
```

- `SELECT *`: 모든 컬럼을 가져온다.
- `FROM actor`: `actor` 테이블에서 가져온다.
- `search_path`가 `dvdrental`이면 `dvdrental.actor`와 같은 뜻이다.
