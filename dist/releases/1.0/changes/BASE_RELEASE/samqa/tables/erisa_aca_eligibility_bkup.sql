-- liquibase formatted sql
-- changeset SAMQA:1754374157921 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\erisa_aca_eligibility_bkup.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/erisa_aca_eligibility_bkup.sql:null:945288c1a94d60c62dfc45f8bd4cf5571429f1e9:create

create table samqa.erisa_aca_eligibility_bkup (
    eligibility_id           number,
    ben_plan_id              number,
    aca_ale_flag             varchar2(1 byte),
    variable_hour_flag       varchar2(1 byte),
    intl_msrmnt_period       number,
    intl_msrmnt_start_date   date,
    intl_admn_period         number,
    stblty_period            number,
    msrmnt_start_date        date,
    msrmnt_period            number,
    msrmnt_end_date          date,
    admn_start_date          date,
    admn_period              number,
    admn_end_date            date,
    stblt_start_date         date,
    stblt_period             number,
    stblt_end_date           date,
    irs_lbm_flag             varchar2(1 byte),
    mnthl_msrmnt_flag        varchar2(1 byte),
    same_prd_bnft_start_date date,
    new_prd_bnft_start_date  date,
    created_by               number,
    creation_date            date,
    last_updated_by          number,
    last_update_date         date
);

