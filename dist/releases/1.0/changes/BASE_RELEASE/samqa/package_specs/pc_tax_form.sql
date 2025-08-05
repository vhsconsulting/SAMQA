-- liquibase formatted sql
-- changeset SAMQA:1754374140773 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_tax_form.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_tax_form.sql:null:6bfce6cbab9e27d704d6094e92d83bb39aa27544:create

create or replace package samqa.pc_tax_form as
    procedure generate_5498 (
        p_tax_year         in varchar2,
        p_generation_month in varchar2,
        p_acc_num          in varchar2
    );-- 2012
    procedure generate_1099 (
        p_tax_year in number,
        p_acc_num  in varchar2
    );

    type tax_record_row_t is record (
            current_year_deposit  number,
            previous_year_deposit number,
            interest              number,
            disbursement          number,
            tax_year              number,
            prev_tax_year         number
    );
    type tax_5498_row_t is record (
            acc_num   varchar2(255),
            name      varchar2(255),
            address   varchar2(255),
            city      varchar2(255),
            state     varchar2(30),
            zip       varchar2(30),
            ssn       varchar2(30),
            box1      varchar2(30),
            box2      varchar2(30),
            box3      varchar2(30),
            box4      varchar2(30),
            box5      varchar2(30),
            corrected varchar2(30)
    );
    type tax_1099_row_t is record (
            acc_num        varchar2(255),
            name           varchar2(255),
            address        varchar2(255),
            city           varchar2(255),
            state          varchar2(30),
            zip            varchar2(30),
            ssn            varchar2(30),
            gross_dist     varchar2(30),
            earn_on_excess varchar2(30),
            fmv_on_dod     varchar2(30),
            corrected      varchar2(30)
    );
    type tax_record_t is
        table of tax_record_row_t;
    type tax_5498_t is
        table of tax_5498_row_t;
    type tax_1099_t is
        table of tax_1099_row_t;
    function get_tax_web (
        p_acc_id in number,
        p_year   in varchar2
    ) return tax_record_t
        pipelined
        deterministic;

    function get_5498_web (
        p_acc_num in varchar2,
        p_year    in varchar2
    ) return tax_5498_t
        pipelined
        deterministic;

    function get_1099_web (
        p_acc_num in varchar2,
        p_year    in varchar2
    ) return tax_1099_t
        pipelined
        deterministic;

    procedure regenerate_5498;

    procedure insert_5500_report (
        p_entrp_id    in number,
        p_ben_plan_id in number,
        p_acc_id      in number,
        p_report_type in varchar2,
        p_user_id     in number
    );

end pc_tax_form;
/

