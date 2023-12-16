rom = [
	'46F8E8C5',
	'460C6085',
	'70F83B8A',
	'284B8303',
	'513E1454',
	'F621ED22',
	'3125065D',
	'11A83A5D',
	'D427686B',
	'713AD82D',
	'4B792F99',
	'2799A4DD',
	'A7901C49',
	'DEDE871A',
	'36C03196',
	'A7EFC249',
	'61A78BB8',
	'3B0A1D2B',
	'4DBFCA76',
	'AE162167',
	'30D76B0A',
	'43192304',
	'F6CC1431',
	'65046380',    
]

offset = 8
for word in rom:
  print(f'lui  t0, 0x00{word[-3:]}')
  print(f'srli t0, t0, 12')
  print(f'lui  t1, 0x{word[:-3]}')
  print(f'or   s1, t0, t1')
  print(f'sw   s1, {offset}(s0)')
  print()
  offset += 4
  