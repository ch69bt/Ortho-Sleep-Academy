class QuizQuestion {
  final String question;
  final List<String> choices;
  final int correctIndex;
  final String explanation;

  const QuizQuestion({
    required this.question,
    required this.choices,
    required this.correctIndex,
    required this.explanation,
  });
}

class QuizCategory {
  final String title;
  final List<QuizQuestion> questions;

  const QuizCategory({required this.title, required this.questions});
}

final List<QuizCategory> quizCategories = [
  QuizCategory(
    title: 'こどもの睡眠編',
    questions: [
      QuizQuestion(
        question: '小学生に推奨される1日の睡眠時間はどれくらいですか？',
        choices: ['6〜7時間', '7〜8時間', '9〜12時間', '13時間以上'],
        correctIndex: 2,
        explanation: '小学生には9〜12時間の睡眠が推奨されています。成長ホルモンの分泌や記憶の定着に深い睡眠が不可欠です。',
      ),
      QuizQuestion(
        question: '子どもの成長ホルモンは主にいつ分泌されますか？',
        choices: ['起きているとき', '運動中', '深い睡眠（ノンレム睡眠）中', '食事中'],
        correctIndex: 2,
        explanation: '成長ホルモンは深いノンレム睡眠中に最も多く分泌されます。「寝る子は育つ」には科学的根拠があります。',
      ),
      QuizQuestion(
        question: '寝る前にスマホを見ると眠りにくくなる主な理由は何ですか？',
        choices: [
          '画面が明るすぎるから',
          'ブルーライトがメラトニンの分泌を抑制するから',
          '目が疲れるから',
          'ゲームが楽しいから',
        ],
        correctIndex: 1,
        explanation: 'スマホのブルーライトは脳に昼間と錯覚させ、睡眠ホルモン「メラトニン」の分泌を抑えてしまいます。',
      ),
      QuizQuestion(
        question: '朝に日光を浴びると体内時計がリセットされます。その後、約何時間後に眠気が来やすいですか？',
        choices: ['約4時間後', '約8時間後', '約14〜16時間後', '約24時間後'],
        correctIndex: 2,
        explanation: '朝に光を浴びると約14〜16時間後にメラトニンが分泌され始めます。朝7時に光を浴びれば21〜23時頃に自然な眠気が来ます。',
      ),
      QuizQuestion(
        question: '子どもの寝室に適した夜の照度はどれくらいですか？',
        choices: ['500 lux以上', '200〜300 lux', '100 lux前後', '50 lux以下'],
        correctIndex: 3,
        explanation: '就寝前は50 lux以下の暗い環境が理想的です。明るい照明はメラトニンの分泌を妨げ、寝つきを悪くします。',
      ),
    ],
  ),
  QuizCategory(
    title: '大人の睡眠編',
    questions: [
      QuizQuestion(
        question: '成人に推奨される1日の睡眠時間はどれくらいですか？',
        choices: ['5〜6時間', '6〜7時間', '7〜9時間', '10時間以上'],
        correctIndex: 2,
        explanation: 'WHOおよび多くの睡眠研究が成人には7〜9時間を推奨しています。6時間以下の睡眠は認知機能・免疫力の低下につながります。',
      ),
      QuizQuestion(
        question: 'メラトニンが分泌され始める照度の目安はどれくらいですか？',
        choices: ['500 lux以下', '200 lux以下', '100 lux以下', '50 lux以下'],
        correctIndex: 3,
        explanation: '50 lux以下の暗い環境でメラトニンの分泌が促進されます。一般的な室内灯（200〜500 lux）でも分泌が抑制されます。',
      ),
      QuizQuestion(
        question: '入浴は就寝の何時間前が睡眠の質向上に最も効果的ですか？',
        choices: ['30分前', '1〜2時間前', '3〜4時間前', '5時間以上前'],
        correctIndex: 1,
        explanation: '入浴で上がった深部体温が1〜2時間かけて下がるとき、自然な眠気が訪れます。就寝直前の入浴は逆効果になる場合があります。',
      ),
      QuizQuestion(
        question: 'レム睡眠とノンレム睡眠のサイクルは約何分ですか？',
        choices: ['45分', '90分', '120分', '180分'],
        correctIndex: 1,
        explanation: '睡眠は約90分周期でレム睡眠とノンレム睡眠を繰り返します。このサイクルに合わせた睡眠時間（7.5時間など）が目覚めをスッキリさせます。',
      ),
      QuizQuestion(
        question: '睡眠の質を高めるために就寝3時間前から避けるべきものはどれですか？',
        choices: ['水', 'カフェイン・アルコール・強い光', 'ストレッチ', '読書'],
        correctIndex: 1,
        explanation: 'カフェインは覚醒作用、アルコールは睡眠の質を低下させます。強い光はメラトニン分泌を妨げます。これら3つが睡眠の大敵です。',
      ),
    ],
  ),
  QuizCategory(
    title: 'アスリートの睡眠編',
    questions: [
      QuizQuestion(
        question: 'アスリートに推奨される1日の睡眠時間はどれくらいですか？',
        choices: ['6〜7時間', '7〜8時間', '8〜10時間', '12時間以上'],
        correctIndex: 2,
        explanation: '競技アスリートには8〜10時間の睡眠が推奨されています。NBA・NFL選手の研究でも、睡眠時間を延ばすとパフォーマンスが向上することが示されています。',
      ),
      QuizQuestion(
        question: '睡眠不足がアスリートのパフォーマンスに与える影響として正しいものはどれですか？',
        choices: [
          '筋肉量が増える',
          '反応速度・判断力・筋回復が低下する',
          'スタミナが向上する',
          '集中力が高まる',
        ],
        correctIndex: 1,
        explanation: '睡眠不足は反応速度・判断力・筋肉の回復を著しく低下させます。怪我のリスクも高まるため、睡眠はトレーニングの一部です。',
      ),
      QuizQuestion(
        question: '昼寝（パワーナップ）の推奨時間はどれくらいですか？',
        choices: ['10分以下', '20〜30分', '1時間', '2時間以上'],
        correctIndex: 1,
        explanation: '20〜30分の昼寝は午後のパフォーマンスを向上させます。それ以上長くなると深い睡眠に入り、起床後にぼんやりする「睡眠慣性」が起きやすくなります。',
      ),
      QuizQuestion(
        question: '試合前日の睡眠で最も重要なことはどれですか？',
        choices: [
          '前日に10時間以上眠ること',
          '前々日までに十分な睡眠を確保しておくこと',
          '試合直前に2時間昼寝すること',
          '睡眠薬を使うこと',
        ],
        correctIndex: 1,
        explanation: '試合前日は緊張で眠れないことが多いため、前々日・前々々日に十分な睡眠を「貯金」しておくことが重要です。',
      ),
      QuizQuestion(
        question: '朝のトレーニング前に2,500 lux以上の光を浴びると良い理由はどれですか？',
        choices: [
          '筋肉が温まるから',
          '体内時計がリセットされ、覚醒度・集中力が上がるから',
          '日焼けでビタミンDが生成されるから',
          '汗をかきやすくなるから',
        ],
        correctIndex: 1,
        explanation: '強い朝の光は体内時計をリセットし、コルチゾール（覚醒ホルモン）の分泌を促します。集中力・反応速度が向上し、トレーニング効果が高まります。',
      ),
    ],
  ),
];
