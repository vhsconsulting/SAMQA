-- liquibase formatted sql
-- changeset SAMQA:1754374178669 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\sbs_client.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/sbs_client.sql:null:68333498abba55b5817e83d0d9470db645045cfb:create

create or replace force editionable view samqa.sbs_client (
    clientid,
    clientname,
    ein,
    street1,
    street2,
    city,
    state,
    zip,
    effectivedate,
    phone,
    contactemail,
    fax,
    contactfirstname,
    contactlastname,
    enrollmentfee,
    note,
    modifiedby,
    istestclient,
    dba_name,
    termination_date,
    enrollment_date
) as
    select
        "ClientID",
        "ClientName",
        ein,
        "Street1",
        "Street2",
        "City",
        "State",
        "Zip",
        "EffectiveDate",
        "Phone",
        "ContactEmail",
        "Fax",
        "ContactFirstName",
        "ContactLastName",
        "EnrollmentFee",
        "Note",
        "ModifiedBy",
        "IsTestClient",
        dba,
        "TerminationDate",
        "EnrollmentDate"
    from
        client@greatplainsdb;

