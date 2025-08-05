-- liquibase formatted sql
-- changeset SAMQA:1754374146852 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\broker_pers.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/broker_pers.sql:null:ad1cb42a91d48ece54fff0abf192bf9948a851ee:create

alter table samqa.broker
    add constraint broker_pers
        foreign key ( broker_id )
            references samqa.person ( pers_id )
        enable;

