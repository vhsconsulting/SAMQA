-- liquibase formatted sql
-- changeset SAMQA:1754373929888 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\broker_idx1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/broker_idx1.sql:null:e82b62599ab18ba32948662c28da4ed90f3cb944:create

create index samqa.broker_idx1 on
    samqa.broker (
        ga_id
    );

