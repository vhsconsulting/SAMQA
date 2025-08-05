-- liquibase formatted sql
-- changeset SAMQA:1754374135135 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_cobrapoint_migration.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_cobrapoint_migration.sql:null:63a69f4a255afce6be07e2b4454a493aaae49abc:create

create or replace package samqa.pc_cobrapoint_migration as
    type clientdivisionrec is record (
            clientdivisioncontactid number,
            clientdivisionid        number,
            contacttype             varchar2(255),
            salutation              varchar2(50),
            firstname               varchar2(255),
            lastname                varchar2(255),
            email                   varchar2(200),
            title                   varchar2(255),
            department              varchar2(266),
            phone                   varchar2(255),
            phoneextension          varchar2(255),
            phone2                  varchar2(255),
            phone2extension         varchar2(255),
            fax                     varchar2(255),
            address1                varchar2(100),
            address2                varchar2(100),
            city                    varchar2(100),
            state                   varchar2(3),
            postalcode              varchar2(10),
            country                 varchar2(50),
            active                  number,
            loginstatus             varchar2(20),
            registrationcode        varchar2(20),
            registrationdate        timestamp(6),
            allowsso                number,
            ssoidentifier           varchar2(100),
            clientid                number
    );
    type payment_rec is record (
            acc_id        number,
            depositdate   date,
            paymentmethod number,
            amount        number,
            checknumber   varchar2(255),
            note          varchar2(1000),
            qbpaymentid   number,
            creation_date date
    );
    type ssorec is record (
            customerid    number,
            ssoidentifier varchar2(1000),
            memberid      number,
            clientid      number,
            ein           varchar2(255)
    );
    type payment_att is
        table of payment_rec index by pls_integer;
    type ssorec_t is
        table of ssorec;
    procedure migrate_cobra_employer;

    procedure migrate_client_contact;

    procedure migrate_client_division;

    procedure migrate_division_contact;

    procedure migrate_npm (
        p_ssn in varchar2 default null
    );

    function get_broker (
        p_client_id in varchar2
    ) return number;

    procedure migrate_qb (
        p_ssn in varchar2 default null
    );

    procedure migrate_qb_dependent;

    procedure migrate_payments;

    procedure run_migration;
   /* 04/14/2017 , Vanitha: to update the client id since cobrapoint doesnt allow to term */

 --PROCEDURE update_client_id_renewed(p_tax_id IN NUMBER);   -- Commented the procedure by Swamy for Ticket#9656 on 24/03/2021
 -- The below procedure Added by Swamy for Ticket#9656 on 24/03/2021
    procedure update_client_id_renewed (
        p_tax_id       in number,
        p_account_type in varchar2 default 'COBRA'
    );

    function get_client_sso (
        p_ein in varchar2
    ) return ssorec_t
        pipelined
        deterministic;

    function get_qb_sso (
        p_ssn in varchar2
    ) return ssorec_t
        pipelined
        deterministic;

    procedure log_error (
        p_entity_type   in varchar2,
        p_entity_id     in number,
        p_entity_key    in varchar2,
        p_error_message in varchar2
    );

 -- The below procedure Added by Swamy for Ticket#9656 on 24/03/2021
    procedure migrate_spm;

  -- The below procedure Added by Swamy for Ticket#9656 on 24/03/2021
    function get_spm_sso (
        p_ssn in varchar2
    ) return ssorec_t
        pipelined
        deterministic;

 -- The below procedure Added by Swamy for Ticket#9656 on 24/03/2021
    procedure migrate_spm_employer;

end pc_cobrapoint_migration;
/

