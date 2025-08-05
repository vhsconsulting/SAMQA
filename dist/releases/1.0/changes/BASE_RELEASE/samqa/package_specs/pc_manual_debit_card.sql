-- liquibase formatted sql
-- changeset SAMQA:1754374138905 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_manual_debit_card.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_manual_debit_card.sql:null:2be434553ef6103649036b2b9b2a493721ea6bf2:create

create or replace package samqa.pc_manual_debit_card is
    g_tpa_id constant varchar2(30) := 'T00965';
    g_employer_id constant varchar2(30) := 'STLHSA';
    g_plan_id constant varchar2(30) := 'STLHSA';
    g_plan_start_date constant varchar2(30) := '20040101';
    g_plan_end_date constant varchar2(30) := '24000812';
    g_edi_password constant varchar2(30) := 'gca001001';
    type card_creation_rec is record (
            employee_id varchar2(30),
            prefix      varchar2(30),
            last_name   varchar2(255),
            first_name  varchar2(255),
            middle_name varchar2(255),
            address     varchar2(255),
            city        varchar2(255),
            state       varchar2(255),
            zip         varchar2(255),
            gender      varchar2(255),
            birth_date  varchar2(255),
            drivlic     varchar2(255),
            start_date  varchar2(255),
            start_time  varchar2(255),
            email       varchar2(255)
    );
    type card_creation_dep_rec is record (
            employee_id varchar2(30),
            dep_id      varchar2(30),
            last_name   varchar2(255),
            first_name  varchar2(255),
            middle_name varchar2(255),
            address     varchar2(255),
            city        varchar2(255),
            state       varchar2(255),
            zip         varchar2(255),
            relative    varchar2(255)
    );
    type amount_rec is record (
            employee_id      varchar2(30),
            amount           number,
            merchant_name    varchar2(255),
            transaction_date varchar2(30),
            change_num       number
    );
    type account_rec is record (
            employee_id varchar2(30),
            end_date    varchar2(30),
            card_number varchar2(30)
    );
    type lost_stolen_rec is record (
            employee_id varchar2(30),
            prefix      varchar2(30),
            last_name   varchar2(255),
            first_name  varchar2(255),
            middle_name varchar2(255),
            address     varchar2(255),
            city        varchar2(255),
            state       varchar2(255),
            zip         varchar2(255),
            gender      varchar2(255),
            birth_date  varchar2(255),
            drivlic     varchar2(255),
            start_date  varchar2(255),
            start_time  varchar2(255),
            email       varchar2(255),
            card_number varchar2(255)
    );
    type lost_stolen_dep_rec is record (
            employee_id  varchar2(30),
            prefix       varchar2(30),
            last_name    varchar2(255),
            first_name   varchar2(255),
            middle_name  varchar2(255),
            address      varchar2(255),
            city         varchar2(255),
            state        varchar2(255),
            zip          varchar2(255),
            dependant_id number,
            card_number  varchar2(255)
    );
    type dep_account_rec is record (
            employee_id  varchar2(30),
            end_date     varchar2(30),
            dependant_id varchar2(30),
            card_number  varchar2(30)
    );
    type acc_num_change_rec is record (
            old_employee_id varchar2(30),
            employee_id     varchar2(30)
    );
    type varchar2_tab is
        table of varchar2(30) index by binary_integer;
    type card_creation_tab is
        table of card_creation_rec index by binary_integer;
    type lost_stolen_tab is
        table of lost_stolen_rec index by binary_integer;
    type lost_stolen_dep_tab is
        table of lost_stolen_dep_rec index by binary_integer;
    type card_creation_dep_tab is
        table of card_creation_dep_rec index by binary_integer;
    type amount_tab is
        table of amount_rec index by binary_integer;
    type account_tab is
        table of account_rec index by binary_integer;
    type dep_account_tab is
        table of dep_account_rec index by binary_integer;
    type acc_num_change_tab is
        table of acc_num_change_rec index by binary_integer;

  /*** Card creation request will have IB, IC and ID record ****/

    procedure migrate_cards;

    procedure migrate_deposits;

    procedure import_req_export (
        p_record_type      in varchar2,
        p_transaction_type in varchar2,
        p_file_name        in out varchar2
    );

    procedure request_transaction_export (
        p_file_name in out varchar2
    );

    function get_file_name (
        p_action in varchar2,
        p_result in varchar2 default 'RESULT'
    ) return varchar2;

    procedure onetime_terminate (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    );

end pc_manual_debit_card;
/

