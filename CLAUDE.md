# CLAUDE.md

이 파일은 이 저장소에서 작업할 때 Claude Code(claude.ai/code)에게 제공하는 가이드입니다.

## 저장소 개요

`@studyworm`(이승용, studyworm@sicc.co.kr)의 개인 학습/업무 저장소입니다. 일반적인 소프트웨어 프로젝트가 아니며, 현대모비스 레거시 COBOL→Java 전환 작업과 관련된 개인 메모, 프로젝트 문서, 분석 산출물, 단독 실행 유틸리티 코드가 혼재합니다.

실행 가능한 코드는 `05_parser/`에만 있습니다. 그 외 폴더(MDT/, IBM AI/, 250*/)는 한국어로 작성된 문서 및 분석 결과물입니다.

## 05_parser — 정적 분석 도구

IBM AS/400 레거시 COBOL 및 Java 코드베이스를 분석하기 위한 단독 실행 Java 프로그램 3개입니다. **이 저장소에는 빌드 시스템이 없으며**, `jsqlparser`와 `commons-lang3`/`commons-io`를 클래스패스에 추가한 후 IDE(Eclipse, IntelliJ 등)에서 직접 실행합니다.

### 각 클래스의 역할

| 클래스 | 목적 | 입력 | 출력 |
|---|---|---|---|
| `TestParser.java` | COBOL `.cob` 파일에서 CRUD 매트릭스 추출 | `.cob` 파일 디렉터리 | TSV: `파일명 TAB 테이블명 TAB C TAB R TAB U TAB D TAB 파일경로` |
| `TestCallParser.java` | COBOL 프로그램 간 CALL 관계 추출 | `.cob` 파일 디렉터리 | TSV: `파일명 TAB 호출프로그램 TAB 파일경로` |
| `TestJavaParser.java` | Java 파일에서 `.invoke()` 호출 추출 (Java→COBOL 브리지) | `.java` 파일 디렉터리 | TSV: `파일명 TAB 라이브러리.프로그램명 TAB 파일경로` |

세 클래스 모두 `C:\DES_old\workspace\asisdbsrc`와 같이 Windows 경로가 하드코딩되어 있습니다. 실행 전 `main()` 내 `basePath` 변수를 실제 경로로 수정해야 합니다.

### COBOL SQL 파싱 로직 (TestParser)

SQL은 COBOL 내부에 `EXEC SQL` ~ `END-EXEC` 마커 사이에 삽입되어 있습니다. 파서 동작 순서:

1. 주석 제거 — 앞 공백 제거 후 `*`로 시작하는 줄 삭제
2. 공백 정규화 및 COBOL 특수 문법 처리 (`INTO :변수`, `DECLARE ... CURSOR` 등)
3. AS/400 라이브러리/테이블명 하드코딩 목록(`UPARTFLE`, `KPTDB09`, `APARTFLE` 등)을 대상으로 키워드 매칭(완전한 SQL 파싱이 아님)
4. 첫 번째 등장 기준으로 구문 선두 키워드(`INSERT`/`SELECT`/`UPDATE`/`DELETE`)에서 CRUD 유형 결정; 이후 동일 테이블 참조는 읽기(`R`)로 처리

`jsqlparser`(`CCJSqlParserUtil`)는 `TestParser.java`의 `selectTableList` 메서드에 존재하지만 **실제 실행 경로에서는 사용되지 않습니다** — 실제 흐름은 `selectTableList2`/`getTable`의 키워드 매칭 방식을 사용합니다.

### CALL 추출 로직 (TestCallParser)

주석 제거 후 `\nCALL ` ~ `\n` 사이 문자열을 추출합니다. 호출 프로그램명은 작은따옴표 안의 문자열 또는 첫 번째 공백 구분 토큰에서 가져옵니다.

### Java invoke 추출 로직 (TestJavaParser)

Java 소스에서 `.invoke(` 패턴을 찾아 첫 번째와 두 번째 콤마 구분 인자(라이브러리명, 프로그램명)를 추출하여 `라이브러리.프로그램명` 키를 구성합니다. AS/400 프로그램 호출 브리지 패턴에 해당합니다.

### 출력 파일 (05_parser/output/)

MPCA/AMOS 코드베이스를 대상으로 사전 실행한 결과 파일들:

- `ALL_COBOL_CALL.sql` — COBOL→COBOL 호출 그래프
- `ALL_COBOL_CL_CALL.sql` / `ALL_COBOL_CL_SBMJOB_CALL.sql` — CL 프로그램 호출 그래프
- `ALL_CALL_TRANS.sql` — 전환/매핑 테이블
- `JAVA_CRUD.sql` / `JAVA_ALL_TABLE.sql` — Java 측 CRUD 결과
- `ALL_ERROR_*` — 파싱 실패 파일 목록

`sbmjob_cobol_add.csv`는 SBMJOB CL 명령에서 추출한 보조 호출 그래프입니다(컬럼: `cobol, call_cobol, cobol_file, file`).

## 도메인 용어

COBOL→Java 전환(MPCA 스케줄러, 현대모비스 부품 시스템) 프로젝트 배경의 주요 용어:

- **MPCA** — 레거시 IBM AS/400 스케줄러 서브시스템
- **UPARTFLE / KPTDB** — AS/400 라이브러리/테이블 명명 규칙
- **MDT** (Migration Data Transfer) — 트랜잭션 재수행으로 전환 데이터를 검증하는 서브 프로젝트
- **WCA** (Watson Code Assistant) — COBOL→Java 전환을 지원하는 IBM AI 도구
- **Nexacro** — Java 대체 시스템에서 사용하는 UI 프레임워크

## 220828 draggable/

학습 목적으로 작성한 순수 JS 기반 드래그 가능한 `<div>` 실험입니다. 의존성 없음, 빌드 단계 없음.
