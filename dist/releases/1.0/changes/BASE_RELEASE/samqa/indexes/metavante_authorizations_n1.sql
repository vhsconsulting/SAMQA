-- liquibase formatted sql
-- changeset SAMQA:1754373932034 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\metavante_authorizations_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/metavante_authorizations_n1.sql:null:b172d5fb6d2458b7298332490a408c6c0244ae34:create

create index samqa.metavante_authorizations_n1 on
    samqa.metavante_authorizations (
        acc_num
    );

