-- liquibase formatted sql
-- changeset SAMQA:1753779788838 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\lsa_financial_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/lsa_financial_type.sql:null:7d3db725dec59e73a14739a7455e34271ccf9e66:create

create or replace force editionable view samqa.lsa_financial_type (
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
                    a.lookup_name = 'LSA_FINANCIAL'
                and a.lookup_code not in ( 'OTH_FINANCE' )
            union
            select
                10 seq_no,
                meaning,
                lookup_code
            from
                lookups a
            where
                    a.lookup_name = 'LSA_FINANCIAL'
                and a.lookup_code in ( 'OTH_FINANCE' )
        )
    order by
        rownum;

