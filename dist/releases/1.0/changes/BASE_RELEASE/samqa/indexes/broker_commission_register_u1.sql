-- liquibase formatted sql
-- changeset SAMQA:1754373929864 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\broker_commission_register_u1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/broker_commission_register_u1.sql:null:f7d4bff70dafaa7c490ef5e077091afa51332fd3:create

create index samqa.broker_commission_register_u1 on
    samqa.broker_commission_register (
        change_num
    );

