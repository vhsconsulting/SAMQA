-- liquibase formatted sql
-- changeset SAMQA:1754374135791 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_debit_card.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_debit_card.sql:null:c64415a4d1b7323f6d8753138e2d27ced63c0b50:create

create or replace package samqa.pc_debit_card is
    g_tpa_id constant varchar2(30) := 'T00965';
    g_employer_id constant varchar2(30) := 'STLHSA';
    g_plan_id constant varchar2(30) := 'STLHSA';
    g_plan_start_date constant varchar2(30) := '20040101';
    g_plan_end_date constant varchar2(30) := '24000812';
    g_edi_password constant varchar2(30) := 'gca001001';
    g_ftp_url constant varchar2(30) := '216.75.196.23';
    g_ftp_username constant varchar2(30) := 't00965edi';
    g_ftp_password constant varchar2(30) := 'Vn9v4MPk';
    type card_creation_rec is record (
            employee_id     varchar2(30),
            prefix          varchar2(30),
            last_name       varchar2(255),
            first_name      varchar2(255),
            middle_name     varchar2(255),
            address         varchar2(255),
            city            varchar2(255),
            state           varchar2(255),
            zip             varchar2(255),
            gender          varchar2(255),
            birth_date      varchar2(255),
            drivlic         varchar2(255),
            start_date      varchar2(255),
            start_time      varchar2(255),
            email           varchar2(255),
            pers_id         number,
            acc_id          number,
            entrp_id        number,
            er_bps_acc_num  varchar2(255),
            pin_mailer      varchar2(1),
            shipping_method varchar2(1)
    );
    type card_creation_dep_rec is record (
            employee_id     varchar2(30),
            dep_id          varchar2(30),
            last_name       varchar2(255),
            first_name      varchar2(255),
            middle_name     varchar2(255),
            address         varchar2(255),
            city            varchar2(255),
            state           varchar2(255),
            zip             varchar2(255),
            relative        varchar2(255),
            employer_id     varchar2(255),
            pin_mailer      varchar2(1),
            shipping_method varchar2(1)
    );
    type amount_rec is record (
            employee_id      varchar2(30),
            amount           number,
            merchant_name    varchar2(255),
            transaction_date varchar2(30),
            change_num       number
    );
    type adjustment_rec is record (
            employee_id      varchar2(30),
            amount           number,
            merchant_name    varchar2(255),
            transaction_date varchar2(30),
            change_num       number,
            plan_type        varchar2(30),
            employer_id      varchar2(30),
            tracking_number  varchar2(30),
            claim_number     varchar2(30)
    );
    type vendors_rec is record (
            vendor_id   number,
            vendor_name varchar2(255),
            address1    varchar2(255),
            city        varchar2(255),
            state       varchar2(255),
            zip         varchar2(255),
            tax_id      varchar2(255)
    );
    type claim_rec is record (
            employee_id          varchar2(30),
            amount               number,
            merchant_name        varchar2(255),
            transaction_date     varchar2(30),
            change_num           number,
            plan_type            varchar2(30),
            employer_id          varchar2(30),
            reimbursement_method varchar2(30),
            pay_provider         varchar2(30),
            bypass_deductible    varchar2(30),
            provider_id          varchar2(30),
            plan_start_date      varchar2(30),
            plan_end_date        varchar2(30),
            tracking_number      varchar2(30),
            claim_number         varchar2(30)
    );
    type account_rec is record (
            employee_id  varchar2(30),
            end_date     varchar2(30),
            card_number  varchar2(30),
            employer_id  varchar2(30),
            account_type varchar2(30)
    );
    type lost_stolen_rec is record (
            employee_id     varchar2(30),
            prefix          varchar2(30),
            last_name       varchar2(255),
            first_name      varchar2(255),
            middle_name     varchar2(255),
            address         varchar2(255),
            city            varchar2(255),
            state           varchar2(255),
            zip             varchar2(255),
            gender          varchar2(255),
            birth_date      varchar2(255),
            drivlic         varchar2(255),
            start_date      varchar2(255),
            start_time      varchar2(255),
            email           varchar2(255),
            card_number     varchar2(255),
            er_bps_acc_num  varchar2(255),
            pin_mailer      varchar2(1),
            shipping_method varchar2(1)
    );
    type plan_rec is record (
            employer_id      varchar2(30),
            plan_id          varchar2(30),
            employee_id      varchar2(30),
            plan_type        varchar2(30),
            start_date       varchar2(30),
            end_date         varchar2(30),
            status           varchar2(30),
            annual_election  varchar2(30),
            employee_contrib varchar2(30),
            employer_contrib varchar2(30),
            effective_date   varchar2(30),
            termination_date varchar2(30),
            record_number    varchar2(30)
    );
    type dep_plan_rec is record (
            employer_id varchar2(30),
            employee_id varchar2(30),
            dep_id      varchar2(30),
            plan_type   varchar2(30),
            start_date  varchar2(30),
            end_date    varchar2(30)
    );
    type emp_plan_rec is record (
            employer_id         varchar2(30),
            plan_id             varchar2(100),
            plan_type           varchar2(30),
            start_date          varchar2(30),
            end_date            varchar2(30),
            runout_period       varchar2(30),
            minimum_election    varchar2(30),
            maximum_election    varchar2(30),
            grace_period        varchar2(30),
            record_number       varchar2(30),
            iias_enable         varchar2(30),
            iias_options        varchar2(30),
            external_deductible varchar2(30)
    );
    type emp_update_plan_rec is record (
            employer_id      varchar2(30),
            plan_id          varchar2(30),
            plan_type        varchar2(30),
            start_date       varchar2(30),
            end_date         varchar2(30),
            minimum_election varchar2(30),
            maximum_election varchar2(30),
            new_start_date   varchar2(30),
            new_end_date     varchar2(30),
            grace_period     varchar2(30),
            runout_period    varchar2(30),
            record_number    varchar2(30)
    );
    type lost_stolen_dep_rec is record (
            employee_id     varchar2(30),
            prefix          varchar2(30),
            last_name       varchar2(255),
            first_name      varchar2(255),
            middle_name     varchar2(255),
            address         varchar2(255),
            city            varchar2(255),
            state           varchar2(255),
            zip             varchar2(255),
            dependant_id    number,
            card_number     varchar2(255),
            employer_id     varchar2(255),
            pin_mailer      varchar2(1),
            shipping_method varchar2(1)
    );
    type dep_account_rec is record (
            employee_id  varchar2(30),
            end_date     varchar2(30),
            dependant_id varchar2(30),
            card_number  varchar2(30),
            employer_id  varchar2(30),
            account_type varchar2(30)
    );
    type acc_num_change_rec is record (
            old_employee_id varchar2(30),
            employee_id     varchar2(30)
    );
    type hra_acc_num_rec is record (
            old_employee_id varchar2(30),
            employee_id     varchar2(30),
            employer_id     varchar2(30)
    );
    type employer_rec is record (
            employer_id          varchar2(12),
            employer_name        varchar2(255),
            address              varchar2(75)  --changed by joshi from 50 to 75.
            ,
            city                 varchar2(50),
            state                varchar2(50),
            zip                  varchar2(30),
            country              varchar2(50),
            phone_number         varchar2(50),
            fax_number           varchar2(50),
            email_address        varchar2(50),
            setup_email_address  varchar2(255),
            projected_accounts   varchar2(50),
            employer_card_option varchar2(50),
            employer_option      varchar2(50)
    );
    type hra_ee_creation_rec is record (
            employee_id       varchar2(30),
            employer_id       varchar2(30),
            plan_id           varchar2(30),
            plan_type         varchar2(30),
            last_name         varchar2(255),
            first_name        varchar2(255),
            middle_name       varchar2(255),
            address           varchar2(255),
            city              varchar2(255),
            state             varchar2(255),
            zip               varchar2(255),
            gender            varchar2(255),
            birth_date        varchar2(255),
            drivlic           varchar2(255),
            start_date        varchar2(255),
            end_date          varchar2(255),
            effective_date    varchar2(255),
            email             varchar2(255),
            annual_election   varchar2(30),
            debit_card        varchar2(255),
            issue_conditional varchar2(30),
            dep_id            number,
            relative          varchar2(30),
            ssn               varchar2(30),
            pin_mailer        varchar2(1),
            shipping_method   varchar2(1)
    );
    type deposit_rec is record (
            employer_id       varchar2(30),
            employee_id       varchar2(30),
            account_type_code varchar2(30),
            plan_start_date   varchar2(30),
            plan_end_date     varchar2(30),
            plan_name         varchar2(30),
            deposit_type      varchar2(30),
            employee_amount   varchar2(30),
            employer_amount   varchar2(30),
            change_num        varchar2(30),
            transaction_date  varchar2(30),
            merchant_name     varchar2(255),
            effective_date    varchar2(30)
    );
    type debit_card_row_t is record (
            card_number       varchar2(30),
            issue_date        varchar2(30),
            mailed_date       varchar2(30),
            first_name        varchar2(255),
            last_name         varchar2(255),
            ssn               varchar2(255),
            pers_id           number,
            card_id           number,
            status            varchar2(255),
            dob               varchar2(255),
            age               varchar2(255),
            card_status       varchar2(255),
            card_exist        varchar2(255),
            card_proxy_number number,
            employer_number   varchar2(255),
            rn                number
    );
    type debit_card_t is
        table of debit_card_row_t;
    type varchar2_tab is
        table of varchar2(30) index by binary_integer;
    type number_tab is
        table of number index by binary_integer;
    type card_creation_tab is
        table of card_creation_rec index by binary_integer;
    type plan_tab is
        table of plan_rec index by binary_integer;
    type lost_stolen_tab is
        table of lost_stolen_rec index by binary_integer;
    type lost_stolen_dep_tab is
        table of lost_stolen_dep_rec index by binary_integer;
    type card_creation_dep_tab is
        table of card_creation_dep_rec index by binary_integer;
    type amount_tab is
        table of amount_rec index by binary_integer;
    type adjustment_tab is
        table of adjustment_rec index by binary_integer;
    type claim_tab is
        table of claim_rec index by binary_integer;
    type account_tab is
        table of account_rec index by binary_integer;
    type dep_account_tab is
        table of dep_account_rec index by binary_integer;
    type dep_plan_tab is
        table of dep_plan_rec index by binary_integer;
    type emp_plan_tab is
        table of emp_plan_rec index by binary_integer;
    type emp_update_plan_tab is
        table of emp_update_plan_rec index by binary_integer;
    type acc_num_change_tab is
        table of acc_num_change_rec index by binary_integer;
    type hra_acc_num_tab is
        table of hra_acc_num_rec index by binary_integer;
    type employer_tab is
        table of employer_rec index by binary_integer;
    type hra_ee_creation_tab is
        table of hra_ee_creation_rec index by binary_integer;
    type deposit_tab is
        table of deposit_rec index by binary_integer;
    type vendors_tab is
        table of vendors_rec index by binary_integer;

  /*** Card creation request will have IB, IC and ID record ****/

    procedure migrate_cards;

    procedure migrate_deposits;

    procedure insert_alert (
        p_subject in varchar2,
        p_message in varchar2
    );

  -- IMPORT
    procedure card_creation (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    );

    procedure card_adjustments (
        p_acc_num_list      in varchar2 default null,
        p_deposit_file_name in out varchar2
    );

    procedure payment_adjustments (
        p_acc_num_list      in varchar2 default null,
        p_payment_file_name in out varchar2
    );

    procedure demographic_update (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    );

    procedure lost_stolen (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2,
        p_if_file_name in out varchar2
    );

    procedure lost_stolen_reorder (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2,
        p_if_file_name in out varchar2
    );

    procedure unsuspend (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    );

    procedure suspend_card (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    );

    procedure terminate (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    );

    procedure reopen (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    );

    procedure dep_card_creation (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    );

    procedure dep_demographic_update (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    );

    procedure dep_unsuspend (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    );

    procedure dep_lost_stolen (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2,
        p_if_file_name in out varchar2
    );

    procedure dep_lost_stolen_reorder (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2,
        p_if_file_name in out varchar2
    );

    procedure dep_suspend (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    );

    procedure dep_terminate (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    );

    procedure dep_reopen (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    );

    procedure acc_num_change (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    );

    procedure hra_acc_num_change (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    );

    procedure employer_demg (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    );

    procedure import_req_export (
        p_record_type      in varchar2,
        p_transaction_type in varchar2,
        p_file_name        in out varchar2
    );

    procedure request_account_export (
        p_file_name in out varchar2
    );

    procedure request_card_export (
        p_file_name in out varchar2
    );

    procedure request_transaction_export (
        p_file_name in out varchar2
    );

    procedure request_manual_claim_export (
        p_file_name in out varchar2
    );

    procedure update_card_details (
        x_error_message out varchar2,
        x_error_status  out varchar2,
        p_file_name     in out varchar2
    );

    procedure update_card_balance (
        x_error_message out varchar2,
        x_error_status  out varchar2,
        p_file_name     in out varchar2
    );

    procedure post_pending_authorizations (
        x_error_message out varchar2,
        x_error_status  out varchar2,
        p_file_name     in out varchar2
    );

    procedure process_settlements (
        x_error_message out varchar2,
        x_error_status  out varchar2,
        p_file_name     in out varchar2
    );

    procedure process_er_result (
        p_file_name     in varchar2,
        x_error_message out varchar2
    );

    procedure process_result (
        p_file_name     in varchar2,
        x_error_message out varchar2
    );

    procedure process_dependant_result (
        p_file_name     in varchar2,
        x_error_message out varchar2
    );

    function insert_file_seq (
        p_action in varchar2
    ) return number;

    function get_file_name (
        p_action in varchar2,
        p_result in varchar2 default 'RESULT'
    ) return varchar2;

    procedure minimum_fee_adjustments (
        p_acc_num_list      in varchar2 default null,
        p_payment_file_name in out varchar2
    );

    procedure request_pending_auth_export (
        p_file_name in out varchar2
    );

    procedure onetime_terminate (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    );

    procedure update_card_notes (
        p_person_type in varchar2
    );

    procedure card_request_history (
        p_status      in number,
        p_person_type in varchar2
    );

    procedure insert_card_request (
        p_card_id        in number,
        p_acc_num        in varchar2,
        p_status         in number,
        p_error_message  in varchar2,
        p_dependant_card in varchar2,
        p_user_id        in number
    );

    procedure plan_creation (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    );

    procedure reprocess_file (
        p_file_name     in varchar2,
        x_error_message out varchar2,
        x_error_status  out varchar2
    );

    procedure hra_settlement_export (
        p_file_name out varchar2
    );

    procedure hra_ee_creation (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    );

    procedure hra_dep_creation (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    );

    procedure fsa_ee_creation (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    );

    procedure fsa_dep_creation (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    );

    procedure hra_deposits (
        p_acc_num_list      in varchar2 default null,
        p_deposit_file_name in out varchar2
    );

    procedure deposit_annual_election (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    );

    procedure hra_fsa_terminate (
        p_file_name in out varchar2
    );

    procedure hra_fsa_card_creation (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    );

    procedure annual_election (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    );

    procedure hra_fsa_claims (
        p_acc_num_list      in varchar2 default null,
        p_payment_file_name in out varchar2
    );

    procedure vendors (
        p_acc_num_list     in varchar2 default null,
        p_vendor_file_name in out varchar2
    );

    procedure process_vendor_result (
        p_file_name     in varchar2,
        x_error_message out varchar2
    );

    procedure hra_fsa_ee_card_creation (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    );

    procedure hra_fsa_refunds (
        p_deposit_file_name in out varchar2
    );

    procedure hrafsa_suspend_card (
        p_file_name in out varchar2
    );

    procedure hrafsa_unsuspend (
        p_file_name in out varchar2
    );

    function get_ee_card_number (
        p_employee_id in varchar2
    ) return number;

    function get_dep_card_number (
        p_employee_id in varchar2,
        p_dep_id      in varchar2
    ) return number;

    procedure process_card_details;

    function get_card_proxy_number (
        p_card_number in number,
        p_pers_id     in number
    ) return number;

    function get_debit_card (
        p_pers_id in number
    ) return debit_card_t
        pipelined
        deterministic;

    procedure debit_card_offset (
        p_claim_id      in varchar2,
        p_amount        in number,
        p_reason        in varchar2,
        p_user_id       in varchar2,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

  -- 12/23/2013: Zensar group requested that we have to mail out cards before the account
  -- is activated , that means after ID verification and before the account is funded
  -- So this procedure will do cards for the entrp_id : 13475,13476
    procedure custom_card_creation (
        x_file_name out varchar2
    );

    procedure custom_dep_card_creation (
        x_file_name out varchar2
    );

  -- 08/26/2015 :
   -- Procedure to process the suspend/unsuspensation of cards
  -- for substantiated/unsubstantiated debit cards
    procedure process_subst_hrafsa_cards;

    procedure employer_plan_update (
        p_file_name in out varchar2
    );

    function get_webservice_password (
        p_user_name in varchar2
    ) return varchar2;

  --4/27/2022
  -- interest file
    procedure interest_rates (
        p_deposit_file_name in out varchar2
    );

end pc_debit_card;
/

