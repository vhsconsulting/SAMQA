-- liquibase formatted sql
-- changeset SAMQA:1754374153606 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\cms_msp_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/cms_msp_external.sql:null:623d71d3ea5edf1831a2d132d4e20612215a5379:create

create table samqa.cms_msp_external (
    hic_number          char(12 byte),
    sur_name            char(6 byte),
    first_name          char(1 byte),
    birth_date          char(8 byte),
    sex                 char(1 byte),
    dcn                 char(15 byte),
    transaction_type    char(1 byte),
    coverage_type       char(1 byte),
    ssn                 char(9 byte),
    effective_date      char(8 byte),
    termination_date    char(8 byte),
    relationship_code   char(2 byte),
    policy_holder_fname char(9 byte),
    policy_holder_lname char(16 byte),
    policy_holder_ssn   char(9 byte),
    employer_size       char(1 byte),
    group_policy_number char(20 byte),
    ind_policy_number   char(17 byte),
    subscriber_only     char(1 byte),
    employee_status     char(1 byte),
    tin                 char(9 byte),
    tpa_tin             char(9 byte)
)
organization external ( type oracle_loader
    default directory debit_card_dir access parameters (
        records delimited by newline
        fields (
            hic_number position ( 1 : 12 ) char ( 12 ),
            sur_name position ( 13 : 18 ) char ( 6 ),
            first_name position ( 19 : 19 ) char ( 1 ),
            birth_date position ( 20 : 27 ) char ( 8 ),
            sex position ( 28 : 28 ) char ( 1 ),
            dcn position ( 29 : 43 ) char ( 15 ),
            transaction_type position ( 44 : 44 ) char ( 1 ),
            coverage_type position ( 45 : 45 ) char ( 1 ),
            ssn position ( 46 : 54 ) char ( 9 ),
            effective_date position ( 55 : 63 ) char ( 8 ),
            termination_date position ( 63 : 70 ) char ( 8 ),
            relationship_code position ( 71 : 72 ) char ( 2 ),
            policy_holder_fname position ( 73 : 81 ) char ( 9 ),
            policy_holder_lname position ( 82 : 97 ) char ( 16 ),
            policy_holder_ssn position ( 98 : 106 ) char ( 9 ),
            employer_size position ( 107 : 107 ) char ( 1 ),
            group_policy_number position ( 108 : 127 ) char ( 20 ),
            ind_policy_number position ( 128 : 143 ) char ( 17 ),
            subscriber_only position ( 145 : 145 ) char ( 1 ),
            employee_status position ( 145 : 146 ) char ( 1 ),
            tin position ( 147 : 155 ) char ( 9 ),
            tpa_tin position ( 156 : 165 ) char ( 9 )
        )
    ) location ( 'CMS_MSP_081402017093609.txt' )
) reject limit unlimited;

