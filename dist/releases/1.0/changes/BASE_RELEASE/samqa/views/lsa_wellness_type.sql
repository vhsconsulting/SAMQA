-- liquibase formatted sql
-- changeset SAMQA:1754374176720 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\lsa_wellness_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/lsa_wellness_type.sql:null:78e1aac9439cb1ee8482d4462b0ceda948810ca0:create

create or replace force editionable view samqa.lsa_wellness_type (
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
                    a.lookup_name = 'LSA_WELLNESS'
                and a.lookup_code not in ( 'OTHER_WELLNESS' )
            union
            select
                10 seq_no,
                meaning,
                lookup_code
            from
                lookups a
            where
                    a.lookup_name = 'LSA_WELLNESS'
                and a.lookup_code in ( 'OTHER_WELLNESS' )
        )
    order by
        rownum;

