-- liquibase formatted sql
-- changeset SAMQA:1754374157873 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\erisa_aca_eligibility.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/erisa_aca_eligibility.sql:null:bca803709085b3af712704a5423fd92031d98aef:create

create table samqa.erisa_aca_eligibility (
    eligibility_id              number,
    ben_plan_id                 number,
    aca_ale_flag                varchar2(1 byte),
    variable_hour_flag          varchar2(1 byte),
    intl_msrmnt_period          varchar2(100 byte),
    intl_msrmnt_start_date      date,
    intl_admn_period            varchar2(100 byte),
    stblty_period               varchar2(100 byte),
    msrmnt_start_date           date,
    msrmnt_period               varchar2(100 byte),
    msrmnt_end_date             date,
    admn_start_date             date,
    admn_period                 varchar2(100 byte),
    admn_end_date               date,
    stblt_start_date            date,
    stblt_period                varchar2(100 byte),
    stblt_end_date              date,
    irs_lbm_flag                varchar2(1 byte),
    mnthl_msrmnt_flag           varchar2(1 byte),
    same_prd_bnft_start_date    date,
    new_prd_bnft_start_date     date,
    fte_hrs                     varchar2(100 byte),
    fte_look_back               varchar2(100 byte),
    fte_salary_msmrt_period     varchar2(100 byte),
    fte_hourly_msmrt_period     varchar2(100 byte),
    fte_other_msmrt_period      varchar2(100 byte),
    fte_same_period_resume_date varchar2(100 byte),
    fte_diff_period_resume_date varchar2(100 byte),
    fte_other_ee_detail         varchar2(100 byte),
    fte_lkp_other_ee_detail     varchar2(100 byte),
    fte_lkp_salary_msmrt_period varchar2(100 byte),
    fte_lkp_hourly_msmrt_period varchar2(100 byte),
    fte_lkp_other_msmrt_period  varchar2(100 byte),
    created_by                  number,
    creation_date               date default sysdate,
    last_updated_by             number,
    last_update_date            date default sysdate,
    collective_bargain_flag     varchar2(10 byte),
    fte_same_period_select      varchar2(100 byte),
    fte_diff_period_select      varchar2(100 byte),
    define_intl_msrmnt_period   varchar2(100 byte),
    intl_msrmnt_period_det      varchar2(100 byte)
);

alter table samqa.erisa_aca_eligibility add primary key ( eligibility_id )
    using index enable;

