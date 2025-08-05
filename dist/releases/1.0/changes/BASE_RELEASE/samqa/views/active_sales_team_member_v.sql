-- liquibase formatted sql
-- changeset SAMQA:1754374167790 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\active_sales_team_member_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/active_sales_team_member_v.sql:null:93d938c6dc66750fd017617a9627958ff96d412d:create

create or replace force editionable view samqa.active_sales_team_member_v (
    emplr_id,
    broker,
    ga,
    primary_salerep,
    secondary_salesrep,
    customer_srvc_rep
) as
    select
        emplr_id,
        max(broker)             broker,
        max(ga)                 ga,
        max(primary_salerep)    primary_salerep,
        max(secondary_salesrep) secondary_salesrep,
        max(cust_service_rep)   customer_srvc_rep
    from
        (
            select
                emplr_id,
                entity_id broker,
                0         ga,
                0         primary_salerep,
                0         secondary_salesrep,
                0         cust_service_rep
            from
                sales_team_member
            where
                    entity_type = 'BROKER'
                and status = 'A'
            union
            select
                emplr_id,
                0         broker,
                entity_id ga,
                0         primary_salerep,
                0         secondary_salesrep,
                0         cust_service_rep
            from
                sales_team_member
            where
                    entity_type = 'GENERAL_AGENT'
                and status = 'A'
            union
            select
                emplr_id,
                0         broker,
                0         ga,
                entity_id primary_salerep,
                0         secondary_salesrep,
                0         cust_service_rep
            from
                sales_team_member
            where
                    entity_type = 'SALES_REP'
                and mem_role = 'PRIMARY'
    --AND NVL(END_DATE,SYSDATE) >= SYSDATE
                and status = 'A'
            union
            select
                emplr_id,
                0         broker,
                0         ga,
                0         primary_salerep,
                entity_id secondary_salesrep,
                0         cust_service_rep
            from
                sales_team_member
            where
                    entity_type = 'SALES_REP'
                and mem_role = 'SECONDARY'
                and status = 'A'
            union
            select
                emplr_id,
                0         broker,
                0         ga,
                0         primary_salerep,
                0         secondary_salesrep,
                entity_id cust_service_rep
            from
                sales_team_member
            where
                    entity_type = 'CUST_SRVC_REP'
                and status = 'A'
            union
            select
                emplr_id,
                0         broker,
                0         ga,
                0         primary_salerep,
                0         secondary_salesrep,
                entity_id cust_service_rep
            from
                sales_team_member
            where
                    entity_type = 'CS_REP'
                and status = 'A'
        )
    group by
        emplr_id;

