-- liquibase formatted sql
-- changeset SAMQA:1754374140518 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_sam_search.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_sam_search.sql:null:8f37b0f0c48375ee1416e670b30b25ecc28d11d2:create

create or replace package samqa.pc_sam_search is
    type search_person_rec is record (
            last_name       varchar2(255),
            first_name      varchar2(255),
            employer_name   varchar2(255),
            acc_num         varchar2(255),
            ssn             varchar2(255),
            acc_open_start  varchar2(255),
            acc_open_end    varchar2(255),
            acc_reg_start   varchar2(255),
            acc_reg_end     varchar2(255),
            acc_close_start varchar2(255),
            acc_close_end   varchar2(255),
            account_status  varchar2(255),
            complete_flag   varchar2(255),
            vendor_acc      varchar2(255),
            created_by      varchar2(255),
            carrier         varchar2(255),
            closed_reason   varchar2(255),
            sales_rep_id    varchar2(255),
            card_number     varchar2(255),
            account_type    varchar2(255),
            email           varchar2(255),
            fraud_acc       varchar2(255)
    );
    type result_person_rec is record (
            pers_id             number,
            blocked_flag        varchar2(30),
            first_name          varchar2(255),
            middle_name         varchar2(255),
            last_name           varchar2(255),
            ssn                 varchar2(30),
            account_type        varchar2(50),
            primary_account     varchar2(255),
            acc_num             varchar2(30),
            employer            varchar2(255),
            entrp_id            number,
            start_date          varchar2(15),
            end_date            varchar2(15),
            account_manager     varchar2(255),
            salesrep            varchar2(255),
            account_status      varchar2(255),
            broker_name         varchar2(255),
            acc_id              number,
            card_ordered_on     varchar2(30),
            complete_flag       varchar2(10),
            pers_main           number,
            primary_person      varchar2(255),
            user_name           varchar2(100),
            plan_name           varchar2(100),
            first_activity_date varchar2(30),
            closed_reason       varchar2(100)
    );
    type result_cursor_rec is record (
            pers_id        number,
            blocked_flag   varchar2(1),
            first_name     varchar2(255),
            middle_name    varchar2(255),
            last_name      varchar2(255),
            ssn            varchar2(15),
            account_type   varchar2(30),
            acc_num        varchar2(30),
            entrp_id       number,
            start_date     varchar2(15),
            end_date       varchar2(15),
            account_status varchar2(255),
            complete_flag  varchar2(10),
            acc_id         number,
            pers_main      number,
            closed_reason  varchar2(100),
            am_id          number,
            salesrep_id    number,
            broker_id      number,
            created_by     number,
            plan_code      number
    );
    type result_person_t is
        table of result_person_rec;
    function f_search_subscriber (
        p_last_name       in varchar2 default null,
        p_first_name      in varchar2 default null,
        p_employer_name   in varchar2 default null,
        p_acc_num         in varchar2 default null,
        p_ssn             in varchar2 default null,
        p_acc_open_start  in date default null,
        p_acc_open_end    in date default null,
        p_acc_reg_start   in date default null,
        p_acc_reg_end     in date default null,
        p_acc_close_start in date default null,
        p_acc_close_end   in date default null,
        p_account_status  in varchar2 default null,
        p_complete_flag   in varchar2 default null,
        p_vendor_acc      in varchar2 default null,
        p_created_by      in number default null,
        p_carrier         in varchar2 default null,
        p_closed_reason   in varchar2 default null,
        p_sales_rep_id    in number default null,
        p_card_number     in number default null,
        p_account_type    in varchar2 default null,
        p_email           in varchar2 default null,
        p_fraud_acc       in varchar2 default null
    ) return result_person_t
        pipelined
        deterministic;

end pc_sam_search;
/

