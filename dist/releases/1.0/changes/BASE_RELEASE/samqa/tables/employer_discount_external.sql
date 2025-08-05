-- liquibase formatted sql
-- changeset SAMQA:1754374156060 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\employer_discount_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/employer_discount_external.sql:null:da9327891de6af901692130975fb8117253283d4:create

create table samqa.employer_discount_external (
    acc_num                      varchar2(100 byte),
    ongoing_renewal              varchar2(100 byte),
    discount_start_date          varchar2(100 byte),
    discount_exp_date            varchar2(100 byte),
    disccount_reason             varchar2(100 byte),
    renewal_fee                  varchar2(100 byte),
    renewal_fee_calc_type        varchar2(100 byte),
    option_service_fee           varchar2(100 byte),
    option_service_fee_calc_type varchar2(100 byte),
    discount_type                varchar2(10 byte),
    note                         varchar2(4000 byte)
)
organization external ( type oracle_loader
    default directory enroll_dir access parameters (
        records delimited by newline
            skip 1
            badfile 'Employer_Renewal_Discount_Template (FINAL 3-10-25).csv.bad'
            logfile 'Employer_Renewal_Discount_Template (FINAL 3-10-25).csv.log'
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( enroll_dir : 'Employer_Renewal_Discount_Template (FINAL 3-10-25).csv' )
) reject limit 0;

