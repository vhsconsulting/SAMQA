-- liquibase formatted sql
-- changeset SAMQA:1754373929874 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\broker_f1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/broker_f1.sql:null:dca8169b15d52651a3986b317b9c34a2af10eccf:create

create index samqa.broker_f1 on
    samqa.broker ( upper(broker_lic) );

