-- liquibase formatted sql
-- changeset SAMQA:1754374170905 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\cobra_plans_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/cobra_plans_v.sql:null:6841f5b6788e6948ef41de54113d912ae1507144:create

create or replace force editionable view samqa.cobra_plans_v (
    entrp_id,
    clientplanqbid,
    clientid,
    planname,
    carrierplanidentification,
    insurancetype,
    ratetype,
    carrierid,
    carrierenrollmentcontactid,
    carr_csr_contct_id,
    carrierremittancecontactid,
    benefitterminationtype,
    insuredtype,
    waitingperiod,
    fsarenewalmonth,
    agedeterminedby,
    conv_to_idp_allowed,
    monthlyupdaterequired,
    usecoveragelevelnameforqb,
    iscarrierremit,
    aei2009planenrollmentoption,
    adjustwithcarrier,
    disable_carr_notif_del
) as
    select
        c.entrp_id,
        a.clientplanqbid,
        a.clientid,
        a.planname,
        a.carrierplanidentification,
        a.insurancetype,
        a.ratetype,
        a.carrierid,
        a.carrierenrollmentcontactid,
        a.carr_csr_contct_id,
        a.carrierremittancecontactid,
        a.benefitterminationtype,
        a.insuredtype,
        a.waitingperiod,
        a.fsarenewalmonth,
        a.agedeterminedby,
        a.conv_to_idp_allowed,
        a.monthlyupdaterequired,
        a.usecoveragelevelnameforqb,
        a.iscarrierremit,
        a.aei2009planenrollmentoption,
        a.adjustwithcarrier,
        a.disable_carr_notif_del
    from
        clientplanqb a,
        client       b,
        enterprise   c
    where
            a.clientid = b.clientid
        and b.clientid = c.cobra_id_number;

