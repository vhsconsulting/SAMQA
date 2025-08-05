create or replace function samqa.password_verify_function (
    username varchar2,
    password varchar2
) return varchar2 is

    n               boolean;
    m               integer;
    differ          integer;
    isdigit         boolean;
    ischar          boolean;
    ispunct         boolean;
    digitarray      varchar2(20);
    punctarray      varchar2(25);
    chararray       varchar2(52);
    npwdlength      number;
    l_error exception;
    l_error_message varchar2(3200);
    l_new_password  varchar2(3200);
    l_password_used number := 0;
begin
    digitarray := '0123456789';
    chararray := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    punctarray := '!"#$%&()``*+,-/:;<=>?_';

   -- Check if the password is same as the username
    if nls_lower(password) = nls_lower(username) then
        return 'Password same as or similar to user name';
    end if;

   -- Check for the minimum length of the password
    if length(password) < 8 then
        l_error_message := 'Password length cannot be less than 8 characters';
        raise l_error;
    end if;

   -- Check if the password contains at least one letter, one digit and one
   -- punctuation mark.
   -- 1. Check for the digit
    if is_number(password) = 'Y' then
        l_error_message := 'Password must contain atleast one character, one number';
        raise l_error;
    end if;

    if isalphanumeric(password) = 'Y' then
        l_error_message := 'Password cannot contain special characters';
        raise l_error;
    end if;

    if regexp_substr(password, '[A-Za-z]+') = password then
        l_error_message := 'Password must contain atleast one character, one number';
        raise l_error;
    end if;

   -- Added by Joshi to check if last 3 password is same as new password.
   -- ticket. 9804
    l_new_password := sam_password_hash(username, password);
    select
        count(*)
    into l_password_used
    from
        (
            select
                p.password,
                dense_rank()
                over(
                    order by
                        p.creation_date desc
                ) as password_rank
            from
                sam_users_pwd_history p,
                sam_users             u
            where
                    u.user_id = p.user_id
                and u.user_name = lower(username)
        )
    where
            password_rank <= 3
        and password = l_new_password;

    if l_password_used > 0 then
        l_error_message := 'Password should not be similar to last 3 passwords';
        raise l_error;
    end if;
   -- Everything is fine; return TRUE ;

    return null;
exception
    when l_error then
        return l_error_message;
    when others then
        return sqlerrm;
end;
/


-- sqlcl_snapshot {"hash":"31fb64a789350de76d139b1f0a29c5cc12e44d6c","type":"FUNCTION","name":"PASSWORD_VERIFY_FUNCTION","schemaName":"SAMQA","sxml":""}