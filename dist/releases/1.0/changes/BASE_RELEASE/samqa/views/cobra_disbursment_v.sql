-- liquibase formatted sql
-- changeset SAMQA:1754374170746 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\cobra_disbursment_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/cobra_disbursment_v.sql:null:dd21ebf490c1d9c948327366245611cde6ef7d1c:create

create or replace force editionable view samqa.cobra_disbursment_v (
    clientname,
    clientid,
    qb_first_name,
    qb_last_name,
    ssn,
    planname,
    memberid,
    depositdate,
    postmarkdate,
    premiumduedate,
    premium,
    remit,
    policy_number,
    firstname,
    lastname,
    phone,
    address1,
    address2,
    city,
    state,
    postalcode,
    active
) as
    select distinct
        c.clientname,
        c.clientid,
        qb.firstname                                                         qb_first_name,
        qb.lastname                                                          qb_last_name,
        qb.ssn,
        a.planname,
        qb.memberid,
        trunc(a.depositdate)                                                 depositdate,
        trunc(a.postmarkdate)                                                postmarkdate,
        trunc(a.premiumduedate)                                              premiumduedate,
        round(a.premiumamount, 2)                                            premium,
        decode(v.iscarrierremit, 0, 'REMIT_TO_EMPLOYER', 'REMIT_TO_CARRIER') remit,
        v.carrierplanidentification                                          policy_number,
        cc.firstname,
        cc.lastname,
        cc.phone,
        cc.address1,
        cc.address2,
        cc.city,
        cc.state,
        cc.postalcode,
        cc.active
    from
        qbpayment      a,
        qbplan         b,
        clientplanqb   v,
        client         c,
        qb,
        carriercontact cc
    where
            a.planname = b.planname
        and a.memberid = b.memberid
        and b.clientplanqbid = v.clientplanqbid
        and v.carrierremittancecontactid = cc.carriercontactid (+)
 -- AND CC.ACTIVE(+) = '1'
        and trunc(a.postmarkdate) between '01-APR-2016' and '31-APR-2016'
  -- AND TRUNC(A.DEPOSITDATE) BETWEEN '01-MAR-2016' AND '31-MAR-2016'
        and v.clientid = c.clientid
        and qb.memberid = a.memberid
    order by
        c.clientname;

