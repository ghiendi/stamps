import dayjs from 'dayjs';

export function format_db_date(date_input, date_type, show_year = true) {
  if (!date_input) return '';

  // Nếu là Date object -> ISO string, nếu string thì giữ nguyên
  let date_str = typeof date_input === 'string' ? date_input : date_input.toISOString();

  // Parse bằng dayjs, chấp nhận cả DATE ('YYYY-MM-DD') lẫn DATETIME ('YYYY-MM-DD HH:mm:ss')
  const day_obj = dayjs(date_str);

  if (date_type === 'year') {
    return show_year ? day_obj.format('YYYY') : '';
  }
  else if (date_type === 'month') {
    return show_year
      ? day_obj.format('MMM YYYY')
      : day_obj.format('MMM');
  }
  else { // 'day' hoặc mặc định
    return show_year
      ? day_obj.format('DD MMM YYYY')
      : day_obj.format('DD MMM');
  }
}
