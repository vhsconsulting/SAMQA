create or replace package samqa.pc_compliance as
    type contact_row_t is record (
            entrp_name   varchar2(255),
            contact_name varchar2(2000),
            email_list   varchar2(4000),
            cc_list      varchar2(4000),
            deadline     varchar2(30)
    );
    type compliance_row_t is record (
            acc_num         varchar2(255),
            entrp_id        number,
            name            varchar2(4000),
            plan_start      varchar2(30),
            plan_end        varchar2(30),
            plan_start_date date,
            plan_end_date   date,
            template_name   varchar2(255)
    );
    type notification_list_row_t is record (
            acc_num       varchar2(30),
            acc_id        number,
            entrp_id      number,
            ben_plan_id   number,
            plan_end_date date            -- Added by Jaggi #11264
            ,
            product_type  varchar2(30),
            template_name varchar2(255),
            result_notice varchar2(255),
            notice_type   varchar2(255),
            to_list       varchar2(255),
            cc_list       varchar2(255),
            employer_name varchar2(255),
            contact_name  varchar2(255),
            attachment_id number
    );
    type contact_t is
        table of contact_row_t;
    type notification_list_t is
        table of notification_list_row_t;
    type compliance_t is
        table of compliance_row_t;
    procedure insert_benefit_codes (
        p_benefit_code_id    in number,
        p_entity_id          in number,
        p_entity_type        in varchar2,
        p_code_name          in varchar2,
        p_description        in varchar2,
        p_er_contrib         in varchar2 default null,
        p_ee_contrib         in varchar2 default null,
        p_eligibility        in varchar2 default null,
        p_user_id            in number default null,
        p_er_ee_contrib_lng  in varchar2 default null -- Added by Swamy#5518
        ,
        p_refer_to_doc       in varchar2 default null -- Added by Swamy
        ,
        p_fully_insured_flag in varchar2 default null -- Added by rprabu Ticket#7792  23/07/2019
        ,
        p_self_insured_flag  in varchar2 default null -- Added by rprabu Ticket#7792    23/07/2019
        ,
        x_benefit_code_id    out number,
        x_return_status      out varchar2,
        x_error_message      out varchar2
    );

    procedure insert_5500_report (
        p_ben_plan_id in number,
        p_report_type in varchar2,
        p_user_id     in number
    );

    procedure insert_plan_notices (
        p_ben_plan_id in number,
        p_report_type in varchar2,
        p_user_id     in number
    );

    procedure update_eligibility_detail (
        p_benefit_code_id   in number,
        p_er_contrib        in varchar2 default null,
        p_ee_contrib        in varchar2 default null,
        p_eligibility       in varchar2 default null,
        p_user_id           in number default null,
        p_er_ee_contrib_lng in varchar2 default null -- Added by Swamy#5518
        ,
        p_refer_to_doc      in varchar2 default null -- Added by Swamy
        ,
        x_error_message     out varchar2,
        x_return_status     out varchar2
    );

    function get_contact_list (
        p_entrp_id in number
    ) return contact_t
        pipelined
        deterministic;

    function get_compliance_data (
        p_ndt_pref     in varchar2,
        p_ndt_type     in varchar2,
        p_product_type in varchar2
    ) return compliance_t
        pipelined
        deterministic;

    function get_compliance_notify return notification_list_t
        pipelined
        deterministic;

    function get_compliance_followup (
        p_plan_end_from in date,
        p_plan_end_to   in date,
        p_product_type  in varchar2
    ) return compliance_t
        pipelined
        deterministic;
   --PROCEDURE Update_status (p_acc_num in VARCHAR2)    ;

  -- CMS Reporting
    procedure export_cms_query_file (
        x_file_name out varchar2
    );

    procedure export_cms_tin_file (
        x_file_name out varchar2
    );

    procedure export_cms_msp_file (
        x_file_name out varchar2
    );

    procedure export_cms_termed_msp_file (
        x_file_name out varchar2
    );

    procedure import_cms_file (
        pv_file_name in varchar2,
        p_user_id    in number
    );

    procedure update_medicare_information;

    procedure update_plan_dates_cms;

    procedure update_tin_result;

    procedure update_msp_result;

    procedure update_compliance_result_sent (
        p_ben_plan_id in number,
        p_notice_type in varchar2
    );

    procedure update_plan_followup (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_plan_type       in varchar2,
        p_notice_type     in varchar2,
        p_user_id         in number
    );
 -- end CMS
end;
/


-- sqlcl_snapshot {"hash":"96b12859ef238b4b1e3a2efb8af1cfba9a464e7b","type":"PACKAGE_SPEC","name":"PC_COMPLIANCE","schemaName":"SAMQA","sxml":""}