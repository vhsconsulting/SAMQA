create or replace force editionable view samqa."COBRA_DISBURSEMENT_V_temp" (
    clientname,
    clientid,
    firstname,
    lastname,
    ssn,
    planname,
    memberid,
    depositdate,
    postmarkdate,
    premiumduedate,
    premium,
    remit
) as
    select distinct
        c.clientname,
        c.clientid,
        qb.firstname,
        qb.lastname,
        qb.ssn,
        a.planname,
        qb.memberid,
        trunc(a.depositdate)                                                 depositdate,
        trunc(a.postmarkdate)                                                postmarkdate,
        trunc(a.premiumduedate)                                              premiumduedate,
        round(a.premiumamount, 2)                                            premium,
        decode(v.iscarrierremit, 0, 'REMIT_TO_EMPLOYER', 'REMIT_TO_CARRIER') remit
    from
        qbpayment    a,
        qbplan       b,
        clientplanqb v,
        client       c,
        qb
    where
            a.planname = b.planname
        and a.memberid = b.memberid
        and b.clientplanqbid = v.clientplanqbid
        and trunc(a.depositdate) <= '31-MAR-2016'
        and trunc(a.depositdate) between '03-MAR-2016' and '04-APR-2016'
        and v.clientid = c.clientid
        and qb.memberid = a.memberid
    order by
        c.clientname;


-- sqlcl_snapshot {"hash":"9f7a591531e591b18804166994e80267fae5cec0","type":"VIEW","name":"COBRA_DISBURSEMENT_V_temp","schemaName":"SAMQA","sxml":""}