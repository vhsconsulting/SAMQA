-- liquibase formatted sql
-- changeset SAMQA:1754374147000 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\eob_detail.samqa.eob_header.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/eob_detail.samqa.eob_header.sql:null:71f6c83cfd83fdd2683092882795eb84d7ac24f5:create

alter table samqa.eob_detail
    add
        foreign key ( eob_id )
            references samqa.eob_header ( eob_id )
        enable;

