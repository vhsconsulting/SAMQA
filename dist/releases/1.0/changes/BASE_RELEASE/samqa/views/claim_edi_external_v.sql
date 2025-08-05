-- liquibase formatted sql
-- changeset SAMQA:1754374169881 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\claim_edi_external_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/claim_edi_external_v.sql:null:d4a049373978dc41e7a7851684959276a7ade759:create

create or replace force editionable view samqa.claim_edi_external_v (
    rn,
    seg,
    s01,
    s02,
    s03,
    s04,
    s05,
    s06,
    s07,
    s08,
    s09,
    s10,
    s11,
    s12,
    s13,
    s14,
    s15,
    s16,
    s17,
    s18
) as
    select
        rownum rn,
        x.seg,
        x.s01,
        x.s02,
        x.s03,
        x.s04,
        x.s05,
        x.s06,
        x.s07,
        x.s08,
        x.s09,
        x.s10,
        x.s11,
        x.s12,
        x.s13,
        x.s14,
        x.s15,
        x.s16,
        x.s17,
        x.s18
    from
        claim_edi_external x;

