create or replace force editionable view samqa.lsa_emo_health_type (
    seq_no,
    meaning,
    lookup_code
) as
    select
        seq_no,
        meaning,
        lookup_code
    from
        (
            select
                rownum seq_no,
                meaning,
                lookup_code
            from
                lookups a
            where
                    a.lookup_name = 'LSA_EMO_HEALTH'
                and a.lookup_code not in ( 'OTHER_EMO_HEALTH' )
            union
            select
                10 seq_no,
                meaning,
                lookup_code
            from
                lookups a
            where
                    a.lookup_name = 'LSA_EMO_HEALTH'
                and a.lookup_code in ( 'OTHER_EMO_HEALTH' )
        )
    order by
        rownum;


-- sqlcl_snapshot {"hash":"b954b886869ba6181356ab9ea173a39aad6cf1d5","type":"VIEW","name":"LSA_EMO_HEALTH_TYPE","schemaName":"SAMQA","sxml":""}