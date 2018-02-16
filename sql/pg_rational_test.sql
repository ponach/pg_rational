create extension pg_rational;

-- input

-- can parse a simple fraction
select '1/3'::rational;
-- can parse negatives
select '-1/3'::rational;
select '1/-3'::rational;

-- SEND works
select rational_send('1/3');

-- too big
select '9223372036854775808/9223372036854775807'::rational;
-- no spaces
select '1 /3'::rational;
-- no zero denominator
select '1/0'::rational;
-- no single numbers
select '1'::rational;
-- no garbage
select ''::rational;
select 'sdfkjsdfj34984538'::rational;

-- simplification

-- double negative becomes positive
select rational_simplify('-1/-3');
-- works with negative value
select rational_simplify('-3/12');
-- don't move negative if it would overflow
select rational_simplify('1/-9223372036854775808');
-- biggest value reduces
select rational_simplify('9223372036854775807/9223372036854775807');
-- smallest value reduces
select rational_simplify('-9223372036854775808/-9223372036854775808');
-- idempotent on simplified expression
select rational_simplify('1/1');

-- addition

-- additive identity
select '0/1'::rational + '1/2';
-- additive inverse
select '1/2'::rational + '-1/2';
-- just regular
select '1/2'::rational + '1/2';
-- forcing intermediate simplification
select '9223372036854775807/9223372036854775807'::rational + '1/1';
-- overflow (sqrt(max)+1)/1 + 1/sqrt(max)
select '3037000501/1'::rational + '1/3037000500';

-- multiplication

-- multiplicative identity
select '1/1'::rational * '1/2';
-- multiplicative inverse
select '2/1'::rational * '1/2';
-- just regular
select '5/8'::rational * '3/5';
-- forcing intermediate simplification
select '9223372036854775807/9223372036854775807'::rational * '2/2';
-- overflow
select '3037000501/3037000500'::rational * '3037000501/3037000500';

-- comparison

-- equal in every way
select '1/1'::rational = '1/1';
-- same equivalence class
select '20/40'::rational = '22/44';
-- negatives work too
select '-20/40'::rational = '-22/44';
-- forcing intermediate simplification
select '3037000501/3037000501'::rational = '3037000501/3037000501';
-- overflow
select '3037000501/3037000500'::rational = '3037000501/3037000500';
-- not everything is equal
select '2/3'::rational = '8/5';

-- negates equality
select '1/1'::rational <> '1/1';
-- forcing intermediate simplification
select '3037000501/3037000501'::rational <> '3037000501/3037000501';
-- overflow
select '3037000501/3037000500'::rational <> '3037000501/3037000500';
-- not equal
select '2/3'::rational <> '8/5';

-- less than
select r
  from unnest(ARRAY[
      '3037000501/3037000501',
      '0/9999999',
      '-11/17',
      '3/4',
      '-1/2',
      '5/8',
      '6/9'
    ]::rational[]) as r
order by r asc;
