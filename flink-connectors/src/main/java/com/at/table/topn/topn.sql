

-- https://nightlies.apache.org/flink/flink-docs-release-1.15/docs/dev/table/sql/queries/window-topn/

create table if not exists bid_tbl(
    bidtime timestamp(3),
    price decimal(10,2),
    item string,
    supplier_id string,
    watermark bidtime as bidtime - interval '1' second
)

+-------------------------+--------------------------------+--------------------------------+--------------------------------+
|                 bidtime |                          price |                           item |                    supplier_id |
+-------------------------+--------------------------------+--------------------------------+--------------------------------+
| 2020-04-15 08:05:00.000 |                            4.0 |                              A |                      supplier1 |
| 2020-04-15 08:06:00.000 |                            4.0 |                              C |                      supplier2 |
| 2020-04-15 08:07:00.000 |                            2.0 |                              G |                      supplier1 |
| 2020-04-15 08:08:00.000 |                            2.0 |                              B |                      supplier3 |
| 2020-04-15 08:09:00.000 |                            5.0 |                              D |                      supplier4 |
| 2020-04-15 08:11:00.000 |                            2.0 |                              B |                      supplier3 |
| 2020-04-15 08:13:00.000 |                            1.0 |                              E |                      supplier1 |
| 2020-04-15 08:15:00.000 |                            3.0 |                              H |                      supplier2 |
| 2020-04-15 08:17:00.000 |                            6.0 |                              F |                      supplier5 |
+-------------------------+--------------------------------+--------------------------------+--------------------------------+


select
    *
from
(
    select
        *,
        row_number() over (partition by window_start,window_end order by price desc) as rn
    from
        (
            select
                window_start,
                window_end,
                supplier_id,
                sum(price) as price,
                count(*) as cnt
            from
                table(
                        tumble(
                                table bid_tbl,
                                descriptor(bidtime),
                                interval '10' minutes
                            )
                    ) group by window_start,window_end,supplier_id
        )
) where rn <= 3

+-------------------------+-------------------------+--------------------------------+--------------------------------+----------------------+----------------------+
|            window_start |              window_end |                    supplier_id |                          price |                  cnt |                   rn |
+-------------------------+-------------------------+--------------------------------+--------------------------------+----------------------+----------------------+
| 2020-04-15 08:00:00.000 | 2020-04-15 08:10:00.000 |                      supplier1 |                            6.0 |                    2 |                    1 |
| 2020-04-15 08:00:00.000 | 2020-04-15 08:10:00.000 |                      supplier4 |                            5.0 |                    1 |                    2 |
| 2020-04-15 08:00:00.000 | 2020-04-15 08:10:00.000 |                      supplier2 |                            4.0 |                    1 |                    3 |
| 2020-04-15 08:10:00.000 | 2020-04-15 08:20:00.000 |                      supplier5 |                            6.0 |                    1 |                    1 |
| 2020-04-15 08:10:00.000 | 2020-04-15 08:20:00.000 |                      supplier2 |                            3.0 |                    1 |                    2 |
| 2020-04-15 08:10:00.000 | 2020-04-15 08:20:00.000 |                      supplier3 |                            2.0 |                    1 |                    3 |
+-------------------------+-------------------------+--------------------------------+--------------------------------+----------------------+----------------------+



select
    *
from
(
    select
        bidtime,
        price,
        item,
        supplier_id,
        window_start,
        window_end,
        row_number() over (partition by window_start,window_end order by price desc ) as rn
    from
        table(
                tumble(
                    table bid_tbl,
                        descriptor(bidtime),
                        interval '10' minutes
                    )
            )
) where rn <= 3


+-------------------------+--------------------------------+--------------------------------+--------------------------------+-------------------------+-------------------------+----------------------+
|                 bidtime |                          price |                           item |                    supplier_id |            window_start |              window_end |                   rn |
+-------------------------+--------------------------------+--------------------------------+--------------------------------+-------------------------+-------------------------+----------------------+
| 2020-04-15 08:09:00.000 |                            5.0 |                              D |                      supplier4 | 2020-04-15 08:00:00.000 | 2020-04-15 08:10:00.000 |                    1 |
| 2020-04-15 08:05:00.000 |                            4.0 |                              A |                      supplier1 | 2020-04-15 08:00:00.000 | 2020-04-15 08:10:00.000 |                    2 |
| 2020-04-15 08:06:00.000 |                            4.0 |                              C |                      supplier2 | 2020-04-15 08:00:00.000 | 2020-04-15 08:10:00.000 |                    3 |
| 2020-04-15 08:17:00.000 |                            6.0 |                              F |                      supplier5 | 2020-04-15 08:10:00.000 | 2020-04-15 08:20:00.000 |                    1 |
| 2020-04-15 08:15:00.000 |                            3.0 |                              H |                      supplier2 | 2020-04-15 08:10:00.000 | 2020-04-15 08:20:00.000 |                    2 |
| 2020-04-15 08:11:00.000 |                            2.0 |                              B |                      supplier3 | 2020-04-15 08:10:00.000 | 2020-04-15 08:20:00.000 |                    3 |
+-------------------------+--------------------------------+--------------------------------+--------------------------------+-------------------------+-------------------------+----------------------+


















