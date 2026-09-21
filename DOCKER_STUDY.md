# Docker 공부 노트 (SQL 실습 환경)

이 프로젝트는 Docker로 PostgreSQL을 띄워서 SQL을 연습하는 환경이다.
SQL 문법 정리는 [README.md](README.md), Docker 관련 정리는 이 파일에 둔다.

---

## 1. 프로젝트 파일이 각각 뭔지

| 파일 | 역할 |
|---|---|
| `docker-compose.yml` | "PostgreSQL 컨테이너를 이렇게 띄워라"라는 설계도 |
| `DVD_rental_DDL.sql` | 테이블 구조를 만드는 SQL (`CREATE TABLE ...`). DDL = Data Definition Language |
| `DVD_rental_data.sql` | 테이블에 실제 데이터를 넣는 SQL (`INSERT ...`). 실행하면 `INSERT 0 1`이 계속 찍힌다 |
| `README.md` | SQL 문법 연습 노트 (SELECT, JOIN, CTE 등) |
| `DOCKER_STUDY.md` | 지금 보는 파일. Docker 공부용 |

---

## 2. 기본 개념

### 왜 Docker를 쓰나
PostgreSQL을 내 PC에 직접 설치하면 설치 과정도 복잡하고, 버전이 꼬이거나 지우기도 번거롭다.
Docker를 쓰면 "이미 설치·설정이 끝난 Postgres"를 받아서 바로 실행하고, 필요 없으면 깔끔하게 지울 수 있다.

### 이미지(image)
- **프로그램이 설치된 상태로 통째로 저장된 설치 세트.** 읽기 전용이라 실행해도 내용이 변하지 않는다.
- 여기서는 `postgres:17`. 이름이 `이름:버전(태그)` 형식이다. 즉 "postgres의 17 버전".
- 처음 실행할 때 **Docker Hub**(이미지 저장소)에서 자동으로 내려받는다. 한 번 받으면 PC에 남아서 다음부터는 다운로드 없이 빠르다.

### 컨테이너(container)
- **이미지를 실제로 실행한 것.** 내 PC 안에서 돌아가는 작은 격리 환경이다. 여기서는 `postgres-db`.
- 비유: 이미지는 **붕어빵 틀**, 컨테이너는 **구운 붕어빵**이다.
  - 같은 이미지(틀)로 컨테이너(붕어빵)를 여러 개 만들 수 있다.
  - 컨테이너를 지워도 이미지는 그대로 남아 있다.
  - 컨테이너 안에서 바뀐 내용은 이미지에 반영되지 않는다. 그래서 데이터를 따로 보관하는 볼륨이 필요하다.

### 볼륨(volume)
- **컨테이너 밖에 데이터를 저장하는 공간.** 컨테이너를 지워도 볼륨이 남아 있으면 DB 데이터가 유지된다.
- 컨테이너는 언제든 지우고 새로 만들 수 있는 "일회용", 볼륨은 데이터를 보관하는 "저장 창고"라고 생각하면 된다.

### 포트(port)
- **접속 통로.** 내 PC의 `5432`번으로 접속하면 컨테이너 안 Postgres로 연결된다.
- 컨테이너는 격리돼 있어서, 포트를 열어 주지 않으면 밖(내 PC, VS Code)에서 접속할 수 없다.

### Docker Desktop
- Windows에서 Docker 엔진을 돌려주는 앱. **이게 꺼져 있으면 `docker` 명령이 전부 실패한다.**

### 한눈에 정리

```
이미지 (postgres:17)          ← 설치 세트, 변하지 않음
   │  docker compose up
   ▼
컨테이너 (postgres-db)        ← 실행 중인 Postgres, 지워도 됨
   │  데이터 저장
   ▼
볼륨 (postgres_data)          ← DB 데이터 보관, down -v 해야 지워짐
```

---

## 3. docker-compose.yml 한 줄씩 이해하기

```yaml
services:                        # 띄울 컨테이너 목록
  postgres:                      # 서비스 이름 (내가 붙인 이름)
    image: postgres:17           # 사용할 이미지: PostgreSQL 17
    container_name: postgres-db  # 컨테이너 이름. 로그 앞에 "postgres-db |"로 찍히는 이름
    restart: always              # 꺼지거나 PC를 재부팅하면 자동으로 다시 시작
    environment:                 # 컨테이너 안에 넣어 주는 설정값
      POSTGRES_USER: postgres        # DB 사용자
      POSTGRES_PASSWORD: mypassword  # 비밀번호
      POSTGRES_DB: dvdrental         # 처음에 자동으로 만들 데이터베이스 이름
    ports:
      - "5432:5432"              # "내 PC 포트:컨테이너 포트"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./DVD_rental_DDL.sql:/docker-entrypoint-initdb.d/01-DVD_rental_DDL.sql
      - ./DVD_rental_data.sql:/docker-entrypoint-initdb.d/02-DVD_rental_data.sql

volumes:
  postgres_data:                 # 위에서 쓴 볼륨을 선언
```

### volumes 세 줄이 핵심

1. `postgres_data:/var/lib/postgresql/data`
   - 왼쪽은 Docker가 관리하는 볼륨 이름, 오른쪽은 컨테이너 안에서 Postgres가 데이터를 저장하는 경로.
   - DB 데이터가 컨테이너 밖에 저장되므로 `docker compose down`을 해도 데이터가 남는다.
2. `./DVD_rental_DDL.sql:/docker-entrypoint-initdb.d/01-...`
3. `./DVD_rental_data.sql:/docker-entrypoint-initdb.d/02-...`
   - 왼쪽은 내 PC의 파일(`./`는 이 폴더), 오른쪽은 컨테이너 안 경로. 내 파일을 컨테이너에 연결하는 것이다.
   - `docker-entrypoint-initdb.d`는 Postgres 이미지가 정해 둔 **특수 폴더**다. **DB를 처음 만들 때 딱 한 번**, 이 폴더의 `.sql` 파일을 **이름 순서대로** 자동 실행한다.
   - 그래서 파일 이름 앞에 `01-`, `02-`를 붙였다. 테이블을 먼저 만들고(01) 데이터를 넣어야(02) 하기 때문이다.

### 중요한 규칙: 초기화는 처음 한 번만

볼륨에 이미 데이터가 있으면 `docker-entrypoint-initdb.d`의 SQL은 **다시 실행되지 않는다.**
그래서 처음 `docker compose up` 할 때만 `INSERT 0 1`이 길게 나오고, 두 번째부터는 바로 시작된다.

---

## 4. 실습 시작하는 순서 (매번 이 순서)

1. **Docker Desktop 앱을 켠다.** 왼쪽 아래가 `Engine running`(초록)이 될 때까지 기다린다.
2. 이 프로젝트 폴더에서 터미널을 열고:
   ```powershell
   docker compose up -d
   ```
3. 준비됐는지 확인:
   ```powershell
   docker ps
   ```
   `postgres-db`가 목록에 있고 STATUS가 `Up`이면 된다.
4. VS Code SQLTools로 접속하거나, 터미널에서 직접 접속한다 (5번 참고).
5. 공부가 끝나면:
   ```powershell
   docker compose down
   ```

> 처음 한 번은 `-d` 없이 `docker compose up`으로 로그를 보는 것도 좋다.
> `database system is ready to accept connections`가 보이면 준비 완료다.
> 이 창을 `Ctrl+C`로 끄면 컨테이너도 같이 멈추니, 초기화 중에는 끄지 말 것.

---

## 5. DB 접속하는 방법

### 방법 A. VS Code SQLTools (편한 방법)
확장 두 개가 필요하다: `SQLTools` (`mtxr.sqltools`), `SQLTools PostgreSQL Driver` (`mtxr.sqltools-driver-pg`).
연결 정보:

| 항목 | 값 |
|---|---|
| Server | `localhost` |
| Port | `5432` |
| Database | `dvdrental` |
| Username | `postgres` |
| Password | `mypassword` |

### 방법 B. 컨테이너 안에서 psql 실행
```powershell
docker exec -it postgres-db psql -U postgres -d dvdrental
```
- `docker exec -it`: 실행 중인 컨테이너 안에서 명령을 실행 (`-it`는 키보드로 상호작용하겠다는 뜻)
- `postgres-db`: 컨테이너 이름
- `psql -U postgres -d dvdrental`: 사용자 `postgres`로 `dvdrental` DB에 접속
- 나올 때는 `\q`

psql 안에서 쓰는 유용한 명령:
- `\dt`: 테이블 목록
- `\d 테이블명`: 테이블 구조
- `\dn`: 스키마 목록

---

## 6. 자주 쓰는 Docker 명령

| 명령 | 뜻 |
|---|---|
| `docker compose up` | 컨테이너 시작 (로그가 화면에 계속 나옴) |
| `docker compose up -d` | 백그라운드로 시작 (`-d` = detached) |
| `docker compose down` | 컨테이너 중지 + 삭제. **볼륨(데이터)은 유지** |
| `docker compose down -v` | 컨테이너 + **볼륨까지 삭제**. DB가 완전히 초기화됨 |
| `docker compose stop` / `start` | 삭제하지 않고 잠깐 멈춤 / 다시 시작 |
| `docker ps` | 실행 중인 컨테이너 목록 |
| `docker ps -a` | 꺼진 것까지 전체 목록 |
| `docker logs postgres-db` | 컨테이너 로그 보기 |
| `docker logs -f postgres-db` | 로그를 실시간으로 따라가며 보기 |
| `docker volume ls` | 볼륨 목록 |

---

## 7. 데이터를 망가뜨렸을 때 (초기화)

README.md에서 `DELETE FROM customer;`, `TRUNCATE`, `ALTER TABLE ... RENAME` 같은 연습을 하다 보면 원본 데이터가 망가질 수 있다.
그럴 때는 처음 상태로 되돌리면 된다.

```powershell
docker compose down -v
docker compose up -d
```

`down -v`로 볼륨이 지워지면 다음 `up`에서 초기화 SQL(01, 02)이 다시 실행되어 깨끗한 DVD rental 데이터가 복원된다.
연습하다 망가져도 부담 없이 지우고 다시 하면 되는 이유다.

---

## 8. 겪었던 오류와 해결

### `failed to connect to the docker API at npipe:////./pipe/dockerDesktopLinuxEngine`
- 원인: Docker Desktop이 꺼져 있음.
- 해결: Docker Desktop을 실행하고 `Engine running`이 될 때까지 기다린 뒤 다시 시도.
- 계속 안 되면 `docker version`으로 Server 쪽이 나오는지 확인, `wsl --status` / `wsl --update` 확인.

### `INSERT 0 1`이 끝없이 나온다
- 오류가 아니다. `DVD_rental_data.sql`의 INSERT가 한 줄씩 실행되는 정상 동작이다.
- 로그가 멈추고 `ready to accept connections`가 나오면 끝난 것.

### `port is already allocated` / 5432 포트 충돌
- 원인: 내 PC에 이미 다른 Postgres가 5432를 쓰고 있거나, 예전 컨테이너가 남아 있음.
- 해결: `docker ps -a`로 확인 후 `docker compose down`. 다른 Postgres가 원인이면 그쪽을 끄거나 `ports`를 `"5433:5432"`처럼 바꾸고, 접속할 때 포트도 5433으로 쓴다.

### PowerShell에서 `l` 입력하면 목록이 안 나옴
- PowerShell에는 `l` 명령이 없다. 목록은 `ls` 또는 `dir`.

