//----------------------------------- ͨ�� -------------------------------------
{.$DEFINE DEBUG}
//����ģʽ

{.$DEFINE TrialVersion}
//���ð汾

{$DEFINE UseReport}
//����֧��

{.$DEFINE RandomID}
//ʹ��������

{$DEFINE cxLibrary42}
//Ver4.2���뻷��

{.$DEFINE EnableBackupDB}
//�������ݿ�֧��
{.$DEFINE EnableDoubleDB}
//˫���ݿ�֧��

//---------------------------------- �м�� ------------------------------------
{.$DEFINE ClientMon}
//�����ػ��ͻ���

{$DEFINE HardMon}
//����Ӳ���ػ�

{.$DEFINE GenRODL}
//����RODL��Դ

{$DEFINE COM_MIT}
//����ϵͳģʽ

//ͨ���м��
{$IFDEF COM_MIT}
  {$DEFINE DBPool}
  //�������ݿ�֧��
  {.$DEFINE ChannelPool}
  //����ͨ��֧��
  {.$DEFINE AutoChannel}
  //����ͨ��ƽ��
  {.$DEFINE SAP}
  //����SAP֧��
  {.$DEFINE ClientMon}
  //֧���ػ�����
{$ENDIF}

//--------------------------------- �ض�ϵͳ -----------------------------------
{.$DEFINE COMMON}
//ͨ�ð汾

{$DEFINE SXSW}
//�ض�ϵͳ

//ɽ������
{$IFDEF SXSW}
  {$DEFINE ChkCardFHTime}		
  {$DEFINE COMMON}
  {$DEFINE HYRFID201}
  //�����ͷ
  {$DEFINE TTCEM100}
  //�Զ��տ�Ʊ��
  {$DEFINE MITTruckProber}
  //�������м������
  {$DEFINE MultiReplay}
  //������Ӧ��ģʽ
  {$DEFINE PrintHYEach}
  //�泵�����鵥
  {$DEFINE PrintHeGeZheng}
  {$DEFINE HeGeZhengSimpleData}
  //ʹ�ü򵥺ϸ�֤����(�޼�����)
  {.$DEFINE PrintHuaYanDan}
  //�泵����ʱ��ϸ�֤�����鵥
  {$DEFINE BatchInHYOfBill}
  //���α����ڻ��鵥�ֶ�
  {$DEFINE SanPreHK}
  //ɢװ����ʱԤ�Ͽ�
  {.$DEFINE AutoPoundInManual}
  //�Զ������˹���Ԥ�쳣
  {$DEFINE DaiStepWuCha}
  //��װ�������
  {$DEFINE NoShowPriceChange}
  //����ʾ�۸������ʾ
  {.$DEFINE NoCheckOnPayment}
  //�˿�ʱ��У���ʽ����
  {$DEFINE MicroMsg}
  //ʹ��΢��
  {$DEFINE UseCustomertMoney}
  //������ʹ�ÿͻ�������
  {.$DEFINE PrintHY}
  //������ӡ���鵥
{$ENDIF}

//���紺��
{$IFDEF XXCJ}
  {$DEFINE COMMON}
  {$DEFINE HYRFID201}
  //�����ͷ
  {$DEFINE TTCEM100}
  //�Զ��տ�Ʊ��
  {$DEFINE MITTruckProber}
  //�������м������
  {$DEFINE MultiReplay}
  //������Ӧ��ģʽ
  {$DEFINE PrintHYEach}
  //�泵�����鵥
  {.$DEFINE PrintHeGeZheng}
  {$DEFINE PrintHuaYanDan}
  //�泵����ʱ��ϸ�֤�����鵥
  {$DEFINE BatchInHYOfBill}
  //���α����ڻ��鵥�ֶ�
  {$DEFINE SanPreHK}
  //ɢװ����ʱԤ�Ͽ�
  {.$DEFINE AutoPoundInManual}
  //�Զ������˹���Ԥ�쳣
  {$DEFINE DaiStepWuCha}
  //��װ�������
  {.$DEFINE NoShowPriceChange}
  //����ʾ�۸������ʾ
  {.$DEFINE NoCheckOnPayment}
  //�˿�ʱ��У���ʽ����
  {$DEFINE MicroMsg}
  //ʹ��΢��
  {$DEFINE UseCustomertMoney}
  //������ʹ�ÿͻ�������
  {$DEFINE PrintHY}
  //������ӡ���鵥`
{$ENDIF}

//֣���Ͻ�
{$IFDEF ZZSJ}
  {$DEFINE COMMON}
  {$DEFINE HYRFID201}
  //�����ͷ
  {$DEFINE MITTruckProber}
  //�������м������
  {$DEFINE MultiReplay}
  //������Ӧ��ģʽ
  {$DEFINE PrintHYEach}
  //�泵�����鵥
  {$DEFINE PrintHeGeZheng}
  {$DEFINE PrintHuaYanDan}
  //�泵����ʱ��ϸ�֤�����鵥
  {$DEFINE BatchInHYOfBill}
  //���α����ڻ��鵥�ֶ�
  {$DEFINE SanPreHK}
  //ɢװ����ʱԤ�Ͽ�
  {.$DEFINE AutoPoundInManual}
  //�Զ������˹���Ԥ�쳣
  {$DEFINE DaiStepWuCha}
  //��װ�������
  {$DEFINE NoShowPriceChange}
  //����ʾ�۸������ʾ
  {$DEFINE NoCheckOnPayment}
  //�˿�ʱ��У���ʽ����
  {$DEFINE MicroMsg}
  //ʹ��΢��
  {$DEFINE UseCustomertMoney}
  //������ʹ�ÿͻ�������
  {$DEFINE AutoProId}
  //�Զ����ɹ�Ӧ�̱��
  {$DEFINE PrintHY}
  //������ӡ���鵥
  {$DEFINE BFLED}
  //����С��
  {$DEFINE BDAUDIT}
  //�������
{$ENDIF}

//����Ӫ��
{$IFDEF LNYK}
  {$DEFINE COMMON}
{$ENDIF}

//��������
{$IFDEF DYGL}
  {$DEFINE COMMON}
  {$DEFINE HYRFID201}
  //�����ͷ
  {$DEFINE PrintGLF}
  //��ӡ��·��
  {$DEFINE TruckInNow}
  //������������,��Ҫ���ó����Ŷ�ģʽ
  {$DEFINE NoCheckOnPayment}
  //�˿�ʱ��У���ʽ����
  {$DEFINE ChangeBillWhenPriceAdjust}
  //ֽ������ʱ�޸���������ݼ۸�
{$ENDIF}

//�綫����
{$IFDEF RDHX}
  {$DEFINE COMMON}
  {$DEFINE HYRFID201}
  //�����ͷ
{$ENDIF}

//�°�����
{$IFDEF XAZL}
  {$DEFINE UseERP_K3}
  //ʹ��k3
  {$DEFINE SyncRemote}
  //Զ��ͬ��
  {$DEFINE VerifyK3Stock}
  //����ʱ��֤Ʒ��
  {$DEFINE MicroMsg}
  //΢��֧��
  {$DEFINE BlueCard}
  //����̧��
{$ENDIF}

//��Դ����
{$IFDEF JYZL}
  {$DEFINE UseERP_K3}
  //ʹ��k3
  {$DEFINE SyncRemote}
  //Զ��ͬ��
  {$DEFINE VerifyK3Stock}
  //����ʱ��֤Ʒ��
  {$DEFINE HYRFID201}
  //�����ͷ
  {$DEFINE AppAtTaskBar}
  //״̬����ʾ
  {$DEFINE PrintBillMoney}
  //��ӡʱ�Խ��
  {$DEFINE HR1847}
  //�������𳵼�
{$ENDIF}

//���Ϻ���
{$IFDEF YNHT}
  {$DEFINE UseERP_K3}
  //ʹ��k3
  {$DEFINE SyncRemote}
  //Զ��ͬ��
  {$DEFINE HYRFID201}
  //�����ͷ
  {$DEFINE AppAtTaskBar}
  //״̬����ʾ
  {$DEFINE PrintBillMoney}
  //��ӡʱ�Խ��
  {$DEFINE MITTruckProber}
  //�������м������
  {$DEFINE UseK3SalePlan}
  //K3���ۼƻ�
  {$DEFINE MultiReplay}
  //������Ӧ��ģʽ
  {$DEFINE NoShowPriceChange}
  //����ʾ�۸������ʾ
  {$DEFINE BatchInHYOfBill}
  //���α����ڻ��鵥�ֶ�
  {$DEFINE AutoPoundInManual}
  //�Զ������˹���Ԥ�쳣
  {$DEFINE PrintHYEach}
  //�泵�����鵥
  {$DEFINE PrintHeGeZheng}
  {.$DEFINE PrintHuaYanDan}
  //�泵����ʱ��ϸ�֤�����鵥
  {$DEFINE HeGeZhengSimpleData}
  //ʹ�ü򵥺ϸ�֤����(�޼�����)
  {.$DEFINE UseUTFDecode}
  //ʹ��UTF�������
  {$DEFINE MicroMsg}
  //ʹ��΢��
{$ENDIF}
