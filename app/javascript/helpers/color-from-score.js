export default function colorFromScore(score) {
  if (score === -1.0) return '';

  if (score <= 0.25) return 'red';
  if (score <= 0.5) return 'light-red';
  if (score <= 1.5) return 'green';
  if (score <= 1.75) return 'light-blue';
  return 'blue';
}