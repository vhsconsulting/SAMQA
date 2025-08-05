-- liquibase formatted sql
-- changeset SAMQA:1754374147110 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\investment_entrp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/investment_entrp.sql:null:4b79de47197d18d841b375fe7861a1f9e18b2782:create

alter table samqa.investment
    add constraint investment_entrp
        foreign key ( invest_id )
            references samqa.enterprise ( entrp_id )
        enable;

