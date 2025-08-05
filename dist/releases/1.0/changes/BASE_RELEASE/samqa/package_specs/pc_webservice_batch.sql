-- liquibase formatted sql
-- changeset SAMQA:1754374142271 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_webservice_batch.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_webservice_batch.sql:null:c1972eb72a707391342e7457c4d104fcf196cdd5:create

create or replace package samqa.pc_webservice_batch as
    type person_rec is record (
            first_name  varchar2(255),
            middle_name varchar2(255),
            last_name   varchar2(255),
            address     varchar2(255),
            city        varchar2(255),
            state       varchar2(255),
            zip         varchar2(255),
            acc_num     varchar2(255)
  -- , birth_date   VARCHAR2(255)
  -- , date_type    VARCHAR2(255)
  -- , ssn          VARCHAR2(255)
    );
    type ssn_rec is record (
            rn            number,
            acc_num       varchar2(255),
            source_system varchar2(255),
            first_name    varchar2(255),
            middle_name   varchar2(255),
            last_name     varchar2(255),
            address       varchar2(255),
            city          varchar2(255),
            state         varchar2(255),
            zip           varchar2(255),
            birth_date    varchar2(255),
            date_type     varchar2(255),
            ssn           varchar2(255)
    );
    type person_tab is
        table of person_rec index by binary_integer;
    type ssn_tab is
        table of ssn_rec index by binary_integer;
    type template_person_rec is record (
            person_name   varchar2(255),
            email         varchar2(255),
            employer      varchar2(255),
            template_name varchar2(255),
            subject       varchar2(255),
            entrp_email   varchar2(255),
            acc_id        varchar2(255),
            acc_num       varchar2(255),
            user_name     varchar2(255),
            contrib_amt   number
    );
    type template_person_tab is
        table of template_person_rec;
   -- Procedure to generate
   -- files for veratad id checks
   --
    procedure generate_ofac_batch (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    );

    procedure generate_ssn_batch (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    );

    procedure process_ofac_batch (
        p_file_name     in out varchar2,
        x_error_message out varchar2
    );

    procedure process_ssn_batch (
        p_file_name     in out varchar2,
        x_error_message out varchar2
    );

    procedure process_online_verification (
        p_acc_num           in varchar2,
        p_transaction_id    in varchar2,
        p_verification_date in varchar2,
        x_return_status     out varchar2,
        x_error_message     out varchar2
    );

    procedure generate_ssn_batch;

    procedure generate_review_batch;

    function get_notification return pc_online_enroll_dml.notify_t
        pipelined
        deterministic;
    /*Ticket#6588 */
    function get_er_notification return pc_online_enroll_dml.notify_t
        pipelined
        deterministic;

 /*FUNCTION get_template_er_notification(p_acc_num in varchar2)
  RETURN PC_ONLINE_ENROLL_DML.notify_t PIPELINED DETERMINISTIC ;
  */
    /*Ticket#6588 */
    procedure process_manual_verification (
        p_acc_id        in number,
        p_note          in varchar2,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    function get_template_notification (
        p_acc_num      in varchar2,
        p_flg_employer in varchar2
    ) return template_person_tab
        pipelined
        deterministic;

    procedure generate_ofac_batch_aop;

    procedure generate_ssn_batch_aop;

    procedure upd_edi_repo_file_process_flag (
        p_file_name   in varchar2,
        p_vendor_name in varchar2,
        p_feed_type   in varchar2
    );

end;
/

