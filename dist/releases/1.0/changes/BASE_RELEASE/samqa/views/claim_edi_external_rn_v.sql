-- liquibase formatted sql
-- changeset SAMQA:1754374169858 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\claim_edi_external_rn_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/claim_edi_external_rn_v.sql:null:1bafcc09dfb6afeb61c311e326a6c70ab4fd3380:create

create or replace force editionable view samqa.claim_edi_external_rn_v (
    rn,
    next_row
) as
    select
        cv.rn,
        nvl(lead(cv.rn)
            over(partition by cv.seg
                 order by
                     cv.rn
        ),
            (
            select
                count(*)
            from
                claim_edi_external
        )) next_row
    from
        (
            select
                rownum rn,
                x.*
            from
                claim_edi_external x
        ) cv
    where
        s03 = '22';

