-- =============================================================
-- 더미 데이터 생성 스크립트 (Brand 20개 + Product 10만개+)
-- 실행 방법: mysql -u application -papplication loopers < dummy_data.sql
-- =============================================================

SET NAMES utf8mb4;
SET foreign_key_checks = 0;
SET autocommit = 0;

-- =============================================================
-- 1. 브랜드 20개 삽입
-- =============================================================
INSERT INTO brand (name, created_at, updated_at, deleted_at) VALUES
  ('나이키',       NOW() - INTERVAL FLOOR(RAND() * 720) DAY, NOW(), NULL),
  ('아디다스',     NOW() - INTERVAL FLOOR(RAND() * 720) DAY, NOW(), NULL),
  ('뉴발란스',     NOW() - INTERVAL FLOOR(RAND() * 720) DAY, NOW(), NULL),
  ('푸마',         NOW() - INTERVAL FLOOR(RAND() * 720) DAY, NOW(), NULL),
  ('리복',         NOW() - INTERVAL FLOOR(RAND() * 720) DAY, NOW(), NULL),
  ('컨버스',       NOW() - INTERVAL FLOOR(RAND() * 720) DAY, NOW(), NULL),
  ('반스',         NOW() - INTERVAL FLOOR(RAND() * 720) DAY, NOW(), NULL),
  ('언더아머',     NOW() - INTERVAL FLOOR(RAND() * 720) DAY, NOW(), NULL),
  ('챔피언',       NOW() - INTERVAL FLOOR(RAND() * 720) DAY, NOW(), NULL),
  ('노스페이스',   NOW() - INTERVAL FLOOR(RAND() * 720) DAY, NOW(), NULL),
  ('파타고니아',   NOW() - INTERVAL FLOOR(RAND() * 720) DAY, NOW(), NULL),
  ('콜롬비아',     NOW() - INTERVAL FLOOR(RAND() * 720) DAY, NOW(), NULL),
  ('아크테릭스',   NOW() - INTERVAL FLOOR(RAND() * 720) DAY, NOW(), NULL),
  ('살로몬',       NOW() - INTERVAL FLOOR(RAND() * 720) DAY, NOW(), NULL),
  ('호카',         NOW() - INTERVAL FLOOR(RAND() * 720) DAY, NOW(), NULL),
  ('온러닝',       NOW() - INTERVAL FLOOR(RAND() * 720) DAY, NOW(), NULL),
  ('브룩스',       NOW() - INTERVAL FLOOR(RAND() * 720) DAY, NOW(), NULL),
  ('아식스',       NOW() - INTERVAL FLOOR(RAND() * 720) DAY, NOW(), NULL),
  ('스케쳐스',     NOW() - INTERVAL FLOOR(RAND() * 720) DAY, NOW(), NULL),
  ('크록스',       NOW() - INTERVAL FLOOR(RAND() * 720) DAY, NOW(), NULL);

COMMIT;

-- =============================================================
-- 2. 상품 10만개 생성 Stored Procedure
-- =============================================================
DROP PROCEDURE IF EXISTS insert_dummy_products;

DELIMITER $$

CREATE PROCEDURE insert_dummy_products(IN total INT)
BEGIN
  DECLARE i        INT DEFAULT 1;
  DECLARE v_brand  INT;
  DECLARE v_name   VARCHAR(100);
  DECLARE v_price  INT;
  DECLARE v_stock  INT;
  DECLARE v_likes  INT;
  DECLARE v_del    DATETIME;
  DECLARE v_cat    INT;
  DECLARE v_type   INT;
  DECLARE v_created DATETIME;

  WHILE i <= total DO

    -- 브랜드 편중 분포: 나이키·아디다스·뉴발란스가 전체의 40% 차지
    SET v_brand = CASE
      WHEN RAND() < 0.15 THEN 1
      WHEN RAND() < 0.30 THEN 2
      WHEN RAND() < 0.40 THEN 3
      ELSE FLOOR(4 + RAND() * 17)
    END;

    -- 카테고리 결정 (1=신발, 2=상의, 3=하의, 4=아우터, 5=가방, 6=악세사리)
    SET v_cat  = FLOOR(1 + RAND() * 6);
    SET v_type = FLOOR(1 + RAND() * 5);

    -- 상품명: 카테고리 + 타입 + 번호
    SET v_name = CONCAT(
      CASE v_cat
        WHEN 1 THEN CASE v_type
          WHEN 1 THEN '에어맥스 ' WHEN 2 THEN '울트라부스트 '
          WHEN 3 THEN '클라우드 ' WHEN 4 THEN '프레시폼 '
          ELSE '겔카야노 ' END
        WHEN 2 THEN CASE v_type
          WHEN 1 THEN '드라이핏 티셔츠 ' WHEN 2 THEN '클라이마쿨 티셔츠 '
          WHEN 3 THEN '퍼포먼스 셔츠 '   WHEN 4 THEN '베이직 반팔 '
          ELSE '그래픽 롱슬리브 ' END
        WHEN 3 THEN CASE v_type
          WHEN 1 THEN '플렉스 조거 ' WHEN 2 THEN '테크 팬츠 '
          WHEN 3 THEN '트레이닝 팬츠 ' WHEN 4 THEN '카고 와이드 '
          ELSE '슬림핏 데님 ' END
        WHEN 4 THEN CASE v_type
          WHEN 1 THEN '구스다운 패딩 ' WHEN 2 THEN '윈드러너 자켓 '
          WHEN 3 THEN '플리스 집업 '   WHEN 4 THEN '레인재킷 '
          ELSE '쉘 자켓 ' END
        WHEN 5 THEN CASE v_type
          WHEN 1 THEN '백팩 ' WHEN 2 THEN '토트백 '
          WHEN 3 THEN '크로스백 ' WHEN 4 THEN '힙색 '
          ELSE '보스턴백 ' END
        ELSE CASE v_type
          WHEN 1 THEN '스포츠 캡 ' WHEN 2 THEN '양말 3팩 '
          WHEN 3 THEN '손목밴드 ' WHEN 4 THEN '선글라스 '
          ELSE '벨트 ' END
      END,
      i
    );

    -- 가격: 카테고리별 현실적인 가격대
    SET v_price = CASE v_cat
      WHEN 1 THEN (FLOOR(8  + RAND() * 22) * 10000)
      WHEN 2 THEN (FLOOR(2  + RAND() * 8)  * 10000)
      WHEN 3 THEN (FLOOR(3  + RAND() * 10) * 10000)
      WHEN 4 THEN (FLOOR(8  + RAND() * 42) * 10000)
      WHEN 5 THEN (FLOOR(3  + RAND() * 17) * 10000)
      ELSE        (FLOOR(1  + RAND() * 4)  * 10000)
    END;

    -- 재고: 약 3%는 품절(0), 나머지는 1~500개
    SET v_stock = IF(RAND() < 0.03, 0, FLOOR(1 + RAND() * 500));

    -- 좋아요: Power Law 분포 (인기 상품 소수에 집중)
    SET v_likes = FLOOR(POW(RAND(), 4) * 15000);

    -- Soft delete: 약 5% 삭제 처리
    SET v_del = IF(RAND() < 0.05,
      NOW() - INTERVAL FLOOR(RAND() * 180) DAY,
      NULL
    );

    -- 생성일: 최근 2년 내 랜덤
    SET v_created = NOW() - INTERVAL FLOOR(RAND() * 730) DAY;

    INSERT INTO product (brand_id, name, price, stock, like_count, created_at, updated_at, deleted_at)
    VALUES (v_brand, v_name, v_price, v_stock, v_likes, v_created, v_created, v_del);

    -- 5000건마다 커밋 (undo log 폭발 방지)
    IF i MOD 5000 = 0 THEN
      COMMIT;
    END IF;

    SET i = i + 1;
  END WHILE;

  COMMIT;
END$$

DELIMITER ;

-- =============================================================
-- 3. 프로시저 실행 (10만 건)
-- =============================================================
CALL insert_dummy_products(100000);

-- =============================================================
-- 4. 정리
-- =============================================================
DROP PROCEDURE IF EXISTS insert_dummy_products;

SET foreign_key_checks = 1;
SET autocommit = 1;

-- =============================================================
-- 5. 결과 확인
-- =============================================================
SELECT '=== 브랜드별 상품 수 ===' AS info;
SELECT b.name AS 브랜드,
       COUNT(p.id) AS 전체상품수,
       SUM(CASE WHEN p.deleted_at IS NULL THEN 1 ELSE 0 END) AS 활성상품수,
       SUM(CASE WHEN p.deleted_at IS NOT NULL THEN 1 ELSE 0 END) AS 삭제상품수,
       ROUND(AVG(p.price)) AS 평균가격,
       MAX(p.like_count) AS 최대좋아요
FROM brand b
LEFT JOIN product p ON b.id = p.brand_id
GROUP BY b.id, b.name
ORDER BY 전체상품수 DESC;

SELECT '=== 좋아요 구간별 분포 ===' AS info;
SELECT
  CASE
    WHEN like_count = 0                THEN '0'
    WHEN like_count BETWEEN 1 AND 100  THEN '1~100'
    WHEN like_count BETWEEN 101 AND 1000 THEN '101~1000'
    WHEN like_count BETWEEN 1001 AND 5000 THEN '1001~5000'
    ELSE '5000+'
  END AS 좋아요구간,
  COUNT(*) AS 상품수
FROM product
WHERE deleted_at IS NULL
GROUP BY 좋아요구간
ORDER BY MIN(like_count);
