-- liquibase formatted sql
-- changeset SAMQA:1754374146762 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\account_broker.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/account_broker.sql:null:85d99a33f243f618c566924bc141186940723f8c:create

alter table samqa.account
    add constraint account_broker
        foreign key ( broker_id )
            references samqa.broker ( broker_id )
        enable;

