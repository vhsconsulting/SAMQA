-- liquibase formatted sql
-- changeset SAMQA:1754374134047 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_acn_migration.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_acn_migration.sql:null:15d7e78e91513430af3124a4dfed852327f3241d:create

create or replace package samqa.pc_acn_migration as
    type varchar2_tbl is
        table of varchar2(2000) index by binary_integer;
    g_hsa_email varchar2(255) := 'Srinivasa.Swamy@sterlingadministration.com';
    g_cc_email varchar2(4000) := 'Dhanya.Kumar@sterlingadministration.com'
                                 || '; Raghavendra.Joshi@sterlingadministration.com'
                                 || '; VHSQATeam@sterlingadministration.com'
                                 || '; Sujit.Panicker@sterlingadministration.com'
                                 || '; Basavaraju.DM@sterlingadministration.com'
                                 || '; Bharaniguru.Rajendiran@sterlingadministration.com'
                                 || '; Shivani.Jaiswal@sterlingadministration.com'
                                 || '; Srinivasulu.Gudur@sterlingadministration.com'
                                 || '; Rupesh.Aujikar@sterlingadministration.com'
                                 || '; Sonia.Gali@sterlingadministration.com';

 /* TODO enter package declarations (types, exceptions, methods etc) here */
    type employee_record is record (
            acc_id        number,
            first_name    varchar2(255),
            middle_name   varchar2(255),
            last_name     varchar2(255),
            gender        varchar2(30),
            ssn           varchar2(30),
            birth_date    varchar2(30),
            address1      varchar2(255),
            city          varchar2(255),
            state         varchar2(30),
            zip           varchar2(30),
            phone_day     varchar2(255),
            phone_even    varchar2(255),
            email_address varchar2(100),
            user_name     varchar2(100),
            pw_question   varchar2(255),
            pw_answer     varchar2(255)
    );
    procedure insert_acn_employer_migration (
        p_acc_id      in number,
        p_entrp_id    in number,
        p_action_type in varchar2
    );

    procedure update_migrated_employer (
        p_batch_number        in number,
        p_ref_employer_acc_id in varchar2_tbl,
        p_enrollment_status   in varchar2_tbl,
        p_error_message       in varchar2_tbl
    );

    procedure email_migration_status (
        p_batch_number in number,
        p_flg_employer in varchar2
    );

    function is_enable_sso (
        p_acc_id in number
    ) return varchar2;

    function is_employer_migrated (
        p_entrp_id in number
    ) return varchar2;

-- Added by Joshi for HSA employee/individual migration
    procedure populate_acn_migrate_data;

    procedure updt_acn_employee_migrate_sts (
        p_mig_seq        varchar2_tbl,
        p_acc_id         varchar2_tbl,
        p_process_status varchar2_tbl,
        p_error_message  varchar2_tbl
    );

end pc_acn_migration;
/

