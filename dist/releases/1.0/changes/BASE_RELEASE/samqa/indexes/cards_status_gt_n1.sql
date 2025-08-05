-- liquibase formatted sql
-- changeset SAMQA:1754373929994 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\cards_status_gt_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/cards_status_gt_n1.sql:null:04f1fd527c676716fe8c99b8e6d6078fb39db6c2:create

create index samqa.cards_status_gt_n1 on
    samqa.cards_status_gt (
        employee_id
    );

