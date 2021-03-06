
-- https://nightlies.apache.org/flink/flink-docs-release-1.15/docs/dev/table/sql/queries/window-tvf/

create table if not exists bid_tbl
(
    bidtime TIMESTAMP(3),
    price   decimal(10, 2),
    item string,
    watermark for bidtime as bidtime - interval '1' second
)
SELECT *
FROM Bid;
+------------------+-------+------+
|          bidtime | price | item |
+------------------+-------+------+
| 2020-04-15 08:05 |  4.00 | C    |
| 2020-04-15 08:07 |  2.00 | A    |
| 2020-04-15 08:09 |  5.00 | D    |
| 2020-04-15 08:11 |  3.00 | B    |
| 2020-04-15 08:13 |  1.00 | E    |
| 2020-04-15 08:17 |  6.00 | F    |
+------------------+-------+------+



-- ================================================================ TUMBLE WINDOW

select
    *
from
table(
    TUMBLE(
        TABLE bid_tbl,
        DESCRIPTOR(bidtime),
        INTERVAL '10' MINUTES
    )
);
+----+-------------------------+--------------------------------+--------------------------------+-------------------------+-------------------------+-------------------------+
| op |                 bidtime |                          price |                           item |            window_start |              window_end |             window_time |
+----+-------------------------+--------------------------------+--------------------------------+-------------------------+-------------------------+-------------------------+
| +I | 2020-04-15 08:05:00.000 |                            4.0 |                              C | 2020-04-15 08:00:00.000 | 2020-04-15 08:10:00.000 | 2020-04-15 08:09:59.999 |
| +I | 2020-04-15 08:07:00.000 |                            2.0 |                              A | 2020-04-15 08:00:00.000 | 2020-04-15 08:10:00.000 | 2020-04-15 08:09:59.999 |
| +I | 2020-04-15 08:09:00.000 |                            5.0 |                              D | 2020-04-15 08:00:00.000 | 2020-04-15 08:10:00.000 | 2020-04-15 08:09:59.999 |
| +I | 2020-04-15 08:11:00.000 |                            3.0 |                              B | 2020-04-15 08:10:00.000 | 2020-04-15 08:20:00.000 | 2020-04-15 08:19:59.999 |
| +I | 2020-04-15 08:13:00.000 |                            1.0 |                              E | 2020-04-15 08:10:00.000 | 2020-04-15 08:20:00.000 | 2020-04-15 08:19:59.999 |
| +I | 2020-04-15 08:17:00.000 |                            6.0 |                              F | 2020-04-15 08:10:00.000 | 2020-04-15 08:20:00.000 | 2020-04-15 08:19:59.999 |
+----+-------------------------+--------------------------------+--------------------------------+-------------------------+-------------------------+-------------------------+


SELECT
       *
FROM
TABLE(
    TUMBLE(
        DATA => TABLE bid_tbl,
        TIMECOL => DESCRIPTOR(bidtime),
        SIZE => INTERVAL '10' MINUTES
    )
);
+----+-------------------------+--------------------------------+--------------------------------+-------------------------+-------------------------+-------------------------+
| op |                 bidtime |                          price |                           item |            window_start |              window_end |             window_time |
+----+-------------------------+--------------------------------+--------------------------------+-------------------------+-------------------------+-------------------------+
| +I | 2020-04-15 08:05:00.000 |                            4.0 |                              C | 2020-04-15 08:00:00.000 | 2020-04-15 08:10:00.000 | 2020-04-15 08:09:59.999 |
| +I | 2020-04-15 08:07:00.000 |                            2.0 |                              A | 2020-04-15 08:00:00.000 | 2020-04-15 08:10:00.000 | 2020-04-15 08:09:59.999 |
| +I | 2020-04-15 08:09:00.000 |                            5.0 |                              D | 2020-04-15 08:00:00.000 | 2020-04-15 08:10:00.000 | 2020-04-15 08:09:59.999 |
| +I | 2020-04-15 08:11:00.000 |                            3.0 |                              B | 2020-04-15 08:10:00.000 | 2020-04-15 08:20:00.000 | 2020-04-15 08:19:59.999 |
| +I | 2020-04-15 08:13:00.000 |                            1.0 |                              E | 2020-04-15 08:10:00.000 | 2020-04-15 08:20:00.000 | 2020-04-15 08:19:59.999 |
| +I | 2020-04-15 08:17:00.000 |                            6.0 |                              F | 2020-04-15 08:10:00.000 | 2020-04-15 08:20:00.000 | 2020-04-15 08:19:59.999 |
+----+-------------------------+--------------------------------+--------------------------------+-------------------------+-------------------------+-------------------------+


SELECT
    window_start,
    window_end,
    sum(price)
from
table(
    tumble(
        table bid_tbl,
        descriptor(bidtime),
        interval '10' minutes
    )
)
group by window_start, window_end;
+----+-------------------------+-------------------------+--------------------------------+
| op |            window_start |              window_end |                         EXPR$2 |
+----+-------------------------+-------------------------+--------------------------------+
| +I | 2020-04-15 08:00:00.000 | 2020-04-15 08:10:00.000 |                           11.0 |
| +I | 2020-04-15 08:10:00.000 | 2020-04-15 08:20:00.000 |                           10.0 |
+----+-------------------------+-------------------------+--------------------------------+


-- ================================================================ HOP WINDOW

SELECT
    *
FROM
TABLE(
    HOP(
        TABLE bid_tbl,
        DESCRIPTOR(bidtime),
        INTERVAL '5' MINUTES,
        INTERVAL '10' MINUTES
    )
);

SELECT
    *
FROM
TABLE(
    HOP(
        DATA => TABLE bid_tbl,
        TIMECOL => DESCRIPTOR(bidtime),
        SLIDE => INTERVAL '5' MINUTES,
        SIZE => INTERVAL '10' MINUTES
    )
);

+----+-------------------------+--------------------------------+--------------------------------+-------------------------+-------------------------+-------------------------+
| op |                 bidtime |                          price |                           item |            window_start |              window_end |             window_time |
+----+-------------------------+--------------------------------+--------------------------------+-------------------------+-------------------------+-------------------------+
| +I | 2020-04-15 08:05:00.000 |                            4.0 |                              C | 2020-04-15 08:05:00.000 | 2020-04-15 08:15:00.000 | 2020-04-15 08:14:59.999 |
| +I | 2020-04-15 08:05:00.000 |                            4.0 |                              C | 2020-04-15 08:00:00.000 | 2020-04-15 08:10:00.000 | 2020-04-15 08:09:59.999 |
| +I | 2020-04-15 08:07:00.000 |                            2.0 |                              A | 2020-04-15 08:05:00.000 | 2020-04-15 08:15:00.000 | 2020-04-15 08:14:59.999 |
| +I | 2020-04-15 08:07:00.000 |                            2.0 |                              A | 2020-04-15 08:00:00.000 | 2020-04-15 08:10:00.000 | 2020-04-15 08:09:59.999 |
| +I | 2020-04-15 08:09:00.000 |                            5.0 |                              D | 2020-04-15 08:05:00.000 | 2020-04-15 08:15:00.000 | 2020-04-15 08:14:59.999 |
| +I | 2020-04-15 08:09:00.000 |                            5.0 |                              D | 2020-04-15 08:00:00.000 | 2020-04-15 08:10:00.000 | 2020-04-15 08:09:59.999 |
| +I | 2020-04-15 08:11:00.000 |                            3.0 |                              B | 2020-04-15 08:10:00.000 | 2020-04-15 08:20:00.000 | 2020-04-15 08:19:59.999 |
| +I | 2020-04-15 08:11:00.000 |                            3.0 |                              B | 2020-04-15 08:05:00.000 | 2020-04-15 08:15:00.000 | 2020-04-15 08:14:59.999 |
| +I | 2020-04-15 08:13:00.000 |                            1.0 |                              E | 2020-04-15 08:10:00.000 | 2020-04-15 08:20:00.000 | 2020-04-15 08:19:59.999 |
| +I | 2020-04-15 08:13:00.000 |                            1.0 |                              E | 2020-04-15 08:05:00.000 | 2020-04-15 08:15:00.000 | 2020-04-15 08:14:59.999 |
| +I | 2020-04-15 08:17:00.000 |                            6.0 |                              F | 2020-04-15 08:15:00.000 | 2020-04-15 08:25:00.000 | 2020-04-15 08:24:59.999 |
| +I | 2020-04-15 08:17:00.000 |                            6.0 |                              F | 2020-04-15 08:10:00.000 | 2020-04-15 08:20:00.000 | 2020-04-15 08:19:59.999 |
+----+-------------------------+--------------------------------+--------------------------------+-------------------------+-------------------------+-------------------------+


SELECT
    window_satrt,
    window_end,
    sum(price)
FROM
TABLE(
    HOP(
        TABLE bid_tbl,
        DESCRIPTOR(bidtime),
        INTERVAL '5' MINUTES,
        INTERVAL '10' MINUTES
    )
)
GROUP BY window_start,window_end;

+----+-------------------------+-------------------------+--------------------------------+
| op |            window_start |              window_end |                         EXPR$2 |
+----+-------------------------+-------------------------+--------------------------------+
| +I | 2020-04-15 08:00:00.000 | 2020-04-15 08:10:00.000 |                           11.0 |
| +I | 2020-04-15 08:05:00.000 | 2020-04-15 08:15:00.000 |                           15.0 |
| +I | 2020-04-15 08:10:00.000 | 2020-04-15 08:20:00.000 |                           10.0 |
| +I | 2020-04-15 08:15:00.000 | 2020-04-15 08:25:00.000 |                            6.0 |
+----+-------------------------+-------------------------+--------------------------------+


-- ================================================================ CUMULATE WINDOW


SELECT
    *
FROM
TABLE(
    CUMULATE(
        DATA => TABLE bid_tbl,
        TIMECOL => DESCRIPTOR(bidtime),
        STEP => INTERVAL '2' MINUTES,
        SIZE => INTERVAL '10' MINUTES
    )
);

+----+-------------------------+--------------------------------+--------------------------------+-------------------------+-------------------------+-------------------------+
| op |                 bidtime |                          price |                           item |            window_start |              window_end |             window_time |
+----+-------------------------+--------------------------------+--------------------------------+-------------------------+-------------------------+-------------------------+
| +I | 2020-04-15 08:05:00.000 |                            4.0 |                              C | 2020-04-15 08:00:00.000 | 2020-04-15 08:06:00.000 | 2020-04-15 08:05:59.999 |
| +I | 2020-04-15 08:05:00.000 |                            4.0 |                              C | 2020-04-15 08:00:00.000 | 2020-04-15 08:08:00.000 | 2020-04-15 08:07:59.999 |
| +I | 2020-04-15 08:05:00.000 |                            4.0 |                              C | 2020-04-15 08:00:00.000 | 2020-04-15 08:10:00.000 | 2020-04-15 08:09:59.999 |
| +I | 2020-04-15 08:07:00.000 |                            2.0 |                              A | 2020-04-15 08:00:00.000 | 2020-04-15 08:08:00.000 | 2020-04-15 08:07:59.999 |
| +I | 2020-04-15 08:07:00.000 |                            2.0 |                              A | 2020-04-15 08:00:00.000 | 2020-04-15 08:10:00.000 | 2020-04-15 08:09:59.999 |
| +I | 2020-04-15 08:09:00.000 |                            5.0 |                              D | 2020-04-15 08:00:00.000 | 2020-04-15 08:10:00.000 | 2020-04-15 08:09:59.999 |
| +I | 2020-04-15 08:11:00.000 |                            3.0 |                              B | 2020-04-15 08:10:00.000 | 2020-04-15 08:12:00.000 | 2020-04-15 08:11:59.999 |
| +I | 2020-04-15 08:11:00.000 |                            3.0 |                              B | 2020-04-15 08:10:00.000 | 2020-04-15 08:14:00.000 | 2020-04-15 08:13:59.999 |
| +I | 2020-04-15 08:11:00.000 |                            3.0 |                              B | 2020-04-15 08:10:00.000 | 2020-04-15 08:16:00.000 | 2020-04-15 08:15:59.999 |
| +I | 2020-04-15 08:11:00.000 |                            3.0 |                              B | 2020-04-15 08:10:00.000 | 2020-04-15 08:18:00.000 | 2020-04-15 08:17:59.999 |
| +I | 2020-04-15 08:11:00.000 |                            3.0 |                              B | 2020-04-15 08:10:00.000 | 2020-04-15 08:20:00.000 | 2020-04-15 08:19:59.999 |
| +I | 2020-04-15 08:13:00.000 |                            1.0 |                              E | 2020-04-15 08:10:00.000 | 2020-04-15 08:14:00.000 | 2020-04-15 08:13:59.999 |
| +I | 2020-04-15 08:13:00.000 |                            1.0 |                              E | 2020-04-15 08:10:00.000 | 2020-04-15 08:16:00.000 | 2020-04-15 08:15:59.999 |
| +I | 2020-04-15 08:13:00.000 |                            1.0 |                              E | 2020-04-15 08:10:00.000 | 2020-04-15 08:18:00.000 | 2020-04-15 08:17:59.999 |
| +I | 2020-04-15 08:13:00.000 |                            1.0 |                              E | 2020-04-15 08:10:00.000 | 2020-04-15 08:20:00.000 | 2020-04-15 08:19:59.999 |
| +I | 2020-04-15 08:17:00.000 |                            6.0 |                              F | 2020-04-15 08:10:00.000 | 2020-04-15 08:18:00.000 | 2020-04-15 08:17:59.999 |
| +I | 2020-04-15 08:17:00.000 |                            6.0 |                              F | 2020-04-15 08:10:00.000 | 2020-04-15 08:20:00.000 | 2020-04-15 08:19:59.999 |
+----+-------------------------+--------------------------------+--------------------------------+-------------------------+-------------------------+-------------------------+





SELECT
       window_start,
       window_end,
       SUM(price),
       count(*)
FROM TABLE(
        CUMULATE(
            TABLE Bid,
            DESCRIPTOR(bidtime),
            INTERVAL '2' MINUTES,
            INTERVAL '10' MINUTES
        )
)
GROUP BY window_start, window_end;

+----+-------------------------+-------------------------+--------------------------------+----------------------+
| op |            window_start |              window_end |                         EXPR$2 |               EXPR$3 |
+----+-------------------------+-------------------------+--------------------------------+----------------------+
| +I | 2020-04-15 08:00:00.000 | 2020-04-15 08:06:00.000 |                            4.0 |                    1 |
| +I | 2020-04-15 08:00:00.000 | 2020-04-15 08:08:00.000 |                            6.0 |                    2 |
| +I | 2020-04-15 08:00:00.000 | 2020-04-15 08:10:00.000 |                           11.0 |                    3 |
| +I | 2020-04-15 08:10:00.000 | 2020-04-15 08:12:00.000 |                            3.0 |                    1 |
| +I | 2020-04-15 08:10:00.000 | 2020-04-15 08:14:00.000 |                            4.0 |                    2 |
| +I | 2020-04-15 08:10:00.000 | 2020-04-15 08:16:00.000 |                            4.0 |                    2 |
| +I | 2020-04-15 08:10:00.000 | 2020-04-15 08:18:00.000 |                           10.0 |                    3 |
| +I | 2020-04-15 08:10:00.000 | 2020-04-15 08:20:00.000 |                           10.0 |                    3 |
+----+-------------------------+-------------------------+--------------------------------+----------------------+









