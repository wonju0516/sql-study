# SQL 공부 노트 (sql_statements)

이 폴더의 `.sql` 파일에 연습한 쿼리를 모으고, 배운 개념은 이 파일에 정리한다.

## 파일

| 파일 | 내용 |
|---|---|
| `example.sql` | `search_path` 설정과 `SELECT` 기본 예제 |

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

---

## VS Code에서 SQL 실행하기 (SQLTools)

- 왼쪽 원통 아이콘에서 `dvdrental (docker)`에 **Connect**한 뒤 실행한다.
- 실행 방법:
  - 코드 위의 **`Run on active connection`** 클릭
  - `Ctrl+E` 두 번 (맥은 `Command+E` 두 번)
  - 우클릭 → **Run Selected Query**
- 아무것도 선택하지 않으면 커서가 있는 블록이 실행되고, 일부만 실행하려면 그 부분을 선택한다.
- 오른쪽 위 ▶ 버튼은 Code Runner 확장의 것이라 SQL을 실행하지 못한다.
